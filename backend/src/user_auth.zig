const std = @import("std");
const httpz = @import("httpz");
const App = @import("app.zig").App;
const createSession = @import("app.zig").createSession;
const createUser = @import("app.zig").createUser;

pub const UserInfo = struct {
    username: []const u8,
    password: []const u8,
};

pub const SessionInfo = struct {
    session_id: []const u8,
};

pub fn login(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const body = req.body().?;
    const json = try std.json.parseFromSlice(UserInfo, app.allocator.*, body, .{});
    defer json.deinit();

    const username = json.value.username;
    const password = json.value.password;

    const user_id = try app.retrieveUserIdFromUsername(username);
    if (user_id) |id| {
        defer app.allocator.free(id);
        if (try app.checkPassword(id, password)) {
            const session_id = try createSession(app, id);
            defer app.allocator.free(session_id);

            try res.setCookie("session_id", session_id, .{ .max_age = 3600, .path = "/", .secure = true, .same_site = .strict, .http_only = true });
            try res.json(.{ .success = true }, .{});
        } else {
            try res.json(.{ .success = false, .err = "Invalid username or password" }, .{});
        }
    } else {
        try res.json(.{ .success = false, .err = "Invalid username or password" }, .{});
    }
}

pub fn signup(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const body = req.body().?;
    const json = try std.json.parseFromSlice(UserInfo, app.allocator.*, body, .{});
    defer json.deinit();

    const username = json.value.username;
    const password = json.value.password;

    const user_id = try app.retrieveUserIdFromUsername(username);
    if (user_id) |id| {
        // If this code runs, then the username is already taken
        app.allocator.free(id);
        try res.json(.{ .success = false, .err = "Username has already been taken" }, .{});
        return;
    }

    const new_id = try createUser(app, username, password);
    defer app.allocator.free(new_id);

    const session_id = try createSession(app, new_id);
    defer app.allocator.free(session_id);

    try res.setCookie("session_id", session_id, .{ .max_age = 3600, .path = "/", .secure = true, .same_site = .strict, .http_only = true });
    try res.json(.{ .success = true }, .{});
}

pub fn validateSession(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    // First, clean up any expired sessions
    try app.cleanupExpiredSessions();

    const session_id_opt = req.cookies().get("session_id");
    if (session_id_opt) |session_id| {
        const user_id_opt = try app.retrieveUserIdFromSessionId(session_id);
        if (user_id_opt) |user_id| {
            // Now grab the username from the database given our user_id
            var stmt = try app.main_db.prepare("SELECT username FROM users WHERE user_id = ?");
            defer stmt.deinit();
            const username = try stmt.oneAlloc([]const u8, app.allocator.*, .{}, .{ .user_id = user_id });
            if (username) |name| {
                defer app.allocator.free(name);
                try res.json(.{ .success = true, .username = name }, .{});
            } else {
                try res.json(.{ .success = false, .err = "Session is invalid" }, .{});
            }
        } else {
            try res.json(.{ .success = false, .err = "Session is invalid" }, .{});
        }
    } else {
        try res.json(.{ .success = false, .err = "Session is invalid" }, .{});
    }
}

pub fn logout(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const session_id_opt = req.cookies().get("session_id");
    if (session_id_opt) |session_id| {
        // Remove the cookie
        try res.setCookie("session_id", "", .{ .max_age = 0, .path = "/", .secure = true, .same_site = .strict, .http_only = true });

        var stmt = try app.main_db.prepare("DELETE FROM sessions WHERE session_id = ?");
        defer stmt.deinit();
        try stmt.exec(.{}, .{ .session_id = session_id });
    }

    try res.json(.{ .success = true }, .{});
}

pub fn deleteAccount(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const body = req.body().?;
    const json = try std.json.parseFromSlice(UserInfo, app.allocator.*, body, .{});
    defer json.deinit();
    const username = json.value.username;
    const password = json.value.password;

    const user_id = try app.retrieveUserIdFromUsername(username);
    if (user_id) |id| {
        if (try app.checkPassword(id, password)) {
            const session = try app.retrieveSessionIdFromUserId(id);

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
                    const user_id_from_session = try app.retrieveUserIdFromSessionId(session_id);
                    if (user_id_from_session) |user_id_from_session_id| {
                        defer app.allocator.free(user_id_from_session_id);
                        if (!std.mem.eql(u8, user_id_from_session_id, id)) {
                            try res.json(.{ .success = false, .err = "Session is invalid" }, .{});
                            return;
                        }
                    }
                }
                // This is a bug, call it a server error
                try res.json(.{ .success = false, .err = "Server error" }, .{});
                return;
            }

            // It's okay to only use the ID here because the username and password have already been checked
            var stmt = try app.main_db.prepare("DELETE FROM users WHERE user_id = ?");
            defer stmt.deinit();
            try stmt.exec(.{}, .{
                .user_id = id,
            });
        }
    }

    if (user_id) |id| {
        defer app.allocator.free(id);
        try res.json(.{ .success = true }, .{});
    } else {
        try res.json(.{ .success = false, .err = "Invalid username or password" }, .{});
    }
}
