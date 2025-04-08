const sqlite = @import("sqlite");
const std = @import("std");
const httpz = @import("httpz");
const App = @import("../app.zig").App;

const UserInfo = struct {
    username: []const u8,
    password: []const u8,
};

pub const VulnerableAuth = struct {
    vuln_auth_db: *sqlite.Db,
    allocator: *const std.mem.Allocator,
    pub fn init(vuln_auth_db: *sqlite.Db, allocator: *const std.mem.Allocator) VulnerableAuth {
        return VulnerableAuth{ .vuln_auth_db = vuln_auth_db, .allocator = allocator };
    }

    pub fn retrieveUserId(self: *VulnerableAuth, username: []const u8, password: []const u8) !?u32 {
        var stmt = try self.vuln_auth_db.prepare("SELECT id FROM users WHERE username = ? AND password = ?");
        defer stmt.deinit();

        const user_id = try stmt.one(u32, .{}, .{ .username = username, .password = password });
        return user_id;
    }

    pub fn createUser(self: *VulnerableAuth, username: []const u8, password: []const u8) !void {
        var stmt = try self.vuln_auth_db.prepare("INSERT INTO users (username, password) VALUES (?, ?)");
        defer stmt.deinit();

        try stmt.exec(.{}, .{ .username = username, .password = password });
    }

    /// On the caller to free the memory
    pub fn retrieveUser(self: *VulnerableAuth, user_id: u32) !?UserInfo {
        var stmt = try self.vuln_auth_db.prepare("SELECT username, password FROM users WHERE id = ?");
        defer stmt.deinit();

        const user_info = try stmt.oneAlloc(UserInfo, self.allocator.*, .{}, .{ .id = user_id });
        return user_info;
    }

    pub fn clearExpiredUsers(self: *VulnerableAuth) !void {
        // Clear users every 30 minutes, except for the default users
        var stmt = try self.vuln_auth_db.prepare("DELETE FROM users WHERE created_at < datetime('now', '-30 minute') AND id > 8");
        defer stmt.deinit();

        try stmt.exec(.{}, .{});
    }
};

pub fn vulnerableLogin(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const json = try req.json(UserInfo);
    const username = json.?.username;
    const password = json.?.password;

    const id_opt = try app.vuln_auth_exercise.retrieveUserId(username, password);
    if (id_opt) |id| {
        try res.json(.{ .success = true, .user_id = id }, .{});
    } else {
        try res.json(.{ .success = false, .user_id = null, .err = "Invalid username or password" }, .{});
    }
}

pub fn vulnerableSignup(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const json = try req.json(UserInfo);
    const username = json.?.username;
    const password = json.?.password;

    // Check if username is already taken
    var stmt = try app.vuln_auth_exercise.vuln_auth_db.prepare("SELECT id FROM users WHERE username = ?");
    defer stmt.deinit();

    const existing_id = try stmt.one(u32, .{}, .{ .username = username });

    if (existing_id) |_| {
        try res.json(.{ .success = false, .username_taken = true }, .{});
        return;
    }

    // Otherwise go ahead
    try app.vuln_auth_exercise.createUser(username, password);

    const id_opt = try app.vuln_auth_exercise.retrieveUserId(username, password);
    if (id_opt) |id| {
        try res.json(.{ .success = true, .user_id = id }, .{});
    } else {
        try res.json(.{ .success = false, .user_id = null, .err = "Failed to create user" }, .{});
    }
}

pub fn vulnerableRetrieveUserData(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    try app.vuln_auth_exercise.clearExpiredUsers();

    const json = try req.json(u32);
    const user_id = json.?;

    const user_opt = try app.vuln_auth_exercise.retrieveUser(user_id);
    if (user_opt) |user| {
        try res.json(.{ .success = true, .username = user.username, .password = user.password }, .{});
    } else {
        try res.json(.{ .success = false, .username = null, .password = null, .err = "Invalid user ID" }, .{});
    }
}
