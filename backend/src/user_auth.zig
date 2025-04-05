const std = @import("std");
const httpz = @import("httpz");
const App = @import("app.zig").App;

const UserInfo = struct {
    username: []const u8,
    password: []const u8,
};

const SessionInfo = struct {
    session_id: []const u8,
};

/// On the caller to free the memory
fn createSession(app: *App, user_id: []const u8) ![]const u8 {
    const session_id = try app.generateSessionId();

    var stmt = try app.main_db.prepare("INSERT INTO sessions (user_id, session_id, created_at) VALUES (?, ?, CURRENT_TIMESTAMP)");
    defer stmt.deinit();

    try stmt.exec(.{}, .{ .user_id = user_id, .session_id = session_id });

    // Return a new allocation that the caller owns
    return session_id;
}

pub fn login(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const body = req.body().?;
    const json = try std.json.parseFromSlice(UserInfo, app.allocator.*, body, .{});
    defer json.deinit();

    const username = json.value.username;
    const password = json.value.password;

    const user_id = try app.retrieveUserIdFromUsers(username);
    if (user_id) |id| {
        defer app.allocator.free(id);
        if (try app.checkPassword(id, password)) {
            const session_id = try createSession(app, id);
            defer app.allocator.free(session_id);

            res.status = 200;
            try res.setCookie("session_id", session_id, .{ .max_age = 3600, .path = "/", .secure = true, .same_site = .strict, .http_only = true });
        } else {
            res.status = 401;
        }
    } else {
        res.status = 401;
    }
}

pub fn signup(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const body = req.body().?;
    const json = try std.json.parseFromSlice(UserInfo, app.allocator.*, body, .{});
    defer json.deinit();

    const username = json.value.username;
    const password = json.value.password;

    const hash: []u8 = try app.allocator.alloc(u8, 116); // I'm not quite certain how this can be changed, but the hash generated is 116 bytes
    defer app.allocator.free(hash);

    const params: std.crypto.pwhash.argon2.Params = .{ .t = 2, .m = 1000, .p = 1 };
    const options: std.crypto.pwhash.argon2.HashOptions = .{ .allocator = app.allocator.*, .encoding = .phc, .mode = .argon2i, .params = params };

    _ = try std.crypto.pwhash.argon2.strHash(password, options, hash);

    const user_id = try app.retrieveUserIdFromUsers(username);
    if (user_id) |id| {
        // If this code runs, then the username is already taken
        app.allocator.free(id);
        res.status = 400;
        return;
    }

    const new_id = try app.generateUserId();
    defer app.allocator.free(new_id);

    var stmt = try app.main_db.prepare("INSERT INTO users (username, password, id) VALUES (?, ?, ?)");
    defer stmt.deinit();

    try stmt.exec(.{}, .{
        .username = username,
        .password = hash,
        .id = new_id,
    });

    const session_id = try createSession(app, new_id);
    defer app.allocator.free(session_id);

    res.status = 200;
    try res.setCookie("session_id", session_id, .{ .max_age = 3600, .path = "/", .secure = true, .same_site = .strict, .http_only = true });
}

pub fn validateSession(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    // First, clean up any expired sessions
    try app.cleanupExpiredSessions();

    const session_id_opt = req.cookies().get("session_id");
    if (session_id_opt) |session_id| {
        const user_id_opt = try app.retrieveUserIdFromSessions(session_id);
        if (user_id_opt) |user_id| {
            // Now grab the username from the database given our user_id
            var stmt = try app.main_db.prepare("SELECT username FROM users WHERE id = ?");
            defer stmt.deinit();
            const username = try stmt.oneAlloc([]const u8, app.allocator.*, .{}, .{ .id = user_id });
            if (username) |name| {
                defer app.allocator.free(name);
                res.status = 200;
                try res.json(name, .{});
            } else {
                res.status = 401;
                try res.json("Session is invalid", .{});
            }
        } else {
            res.status = 401;
            try res.json("Session is invalid", .{});
        }
    } else {
        res.status = 401;
        try res.json("Session is invalid", .{});
    }
}

pub fn logout(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    // Actually I believe there is an issue because the session id is not cleared, so if the same session id was generated again
    // It would be valid. Very unlikely, but still a bug
    const session_id_opt = req.cookies().get("session_id");
    if (session_id_opt) |session_id| {
        var stmt = try app.main_db.prepare("DELETE FROM sessions WHERE session_id = ?");
        defer stmt.deinit();
        try stmt.exec(.{}, .{ .session_id = session_id });
    }

    res.status = 200;
}

pub fn deleteAccount(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const body = req.body().?;
    const json = try std.json.parseFromSlice(UserInfo, app.allocator.*, body, .{});
    defer json.deinit();
    const username = json.value.username;
    const password = json.value.password;

    const user_id = try app.retrieveUserIdFromUsers(username);
    if (user_id) |id| {
        defer app.allocator.free(id);
        if (try app.checkPassword(id, password)) {
            const session = try app.retrieveSessionIdFromSessions(id);

            if (session) |session_id| {
                defer app.allocator.free(session_id);
                var stmt1 = try app.main_db.prepare("DELETE FROM sessions WHERE user_id = ? AND session_id = ?");
                defer stmt1.deinit();

                try stmt1.exec(.{}, .{
                    .user_id = id,
                    .session_id = session_id,
                });
            } else {
                // One of two things has happened: a bug in my code, or the account doesn't match the session

                // Obtain user_id from session_id (in cookie) and check that it matches the user who is trying to delete their account
                const session_id_opt = req.cookies().get("session_id");
                if (session_id_opt) |session_id| {
                    const user_id_from_session = try app.retrieveUserIdFromSessions(session_id);
                    if (user_id_from_session) |user_id_from_session_id| {
                        defer app.allocator.free(user_id_from_session_id);
                        if (!std.mem.eql(u8, user_id_from_session_id, id)) {
                            res.status = 401;
                            try res.json(.{ .success = false }, .{});
                            return;
                        }
                    } else {
                        // This is a bug, call it a server error
                        res.status = 500;
                        try res.json(.{ .success = false }, .{});
                        return;
                    }
                } else {
                    // This is a bug, call it a server error
                    res.status = 500;
                    try res.json(.{ .success = false }, .{});
                    return;
                }
            }

            // It's okay to only use the ID here because the username and password have already been checked
            var stmt = try app.main_db.prepare("DELETE FROM users WHERE id = ?");
            defer stmt.deinit();
            try stmt.exec(.{}, .{
                .id = id,
            });
            res.status = 200;
            try res.json(.{ .success = true }, .{});
        } else {
            try res.json(.{ .success = false }, .{});
        }
    } else {
        try res.json(.{ .success = false }, .{});
    }
}
