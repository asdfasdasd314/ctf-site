const sqlite = @import("sqlite");
const std = @import("std");
const vuln_auth_exercise = @import("exercises/vulnerable_auth.zig");

pub const App = struct {
    allocator: *const std.mem.Allocator,
    main_db: *sqlite.Db,
    vuln_auth_exercise: *vuln_auth_exercise.VulnerableAuth,

    pub fn init(allocator: *const std.mem.Allocator, main_db: *sqlite.Db, vuln_auth: *vuln_auth_exercise.VulnerableAuth) App {
        return App{ .allocator = allocator, .main_db = main_db, .vuln_auth_exercise = vuln_auth };
    }

    pub fn checkPassword(self: *App, user_id: []const u8, pw: []const u8) !bool {
        const options: std.crypto.pwhash.argon2.VerifyOptions = .{ .allocator = self.allocator.* };
        const hash_opt = try self.retrievePasswordHashFromUserId(user_id);
        if (hash_opt) |hash| {
            defer self.allocator.free(hash);
            std.crypto.pwhash.argon2.strVerify(hash, pw, options) catch |err| switch (err) {
                std.crypto.pwhash.HasherError.PasswordVerificationFailed => {
                    return false;
                },
                else => {
                    return err;
                },
            };
            return true;
        }
        return false;
    }

    /// On the caller to free the memory
    pub fn generateUserId(self: *App) ![]const u8 {
        var prng = std.crypto.random;
        var buf: [16]u8 = undefined;

        while (true) {
            // Generate a random 64-bit user ID
            const new_id = prng.int(usize);
            const temp_hex_id = try std.fmt.bufPrint(&buf, "{x:0>16}", .{new_id});

            // Check if this ID already exists
            var stmt = try self.main_db.prepare("SELECT user_id FROM users WHERE user_id = ?");
            defer stmt.deinit();

            const exists = try stmt.one(usize, .{}, .{ .user_id = temp_hex_id });

            // If ID doesn't exist, we can use it
            if (exists == null) {
                // Allocate memory for the final hex_id
                const hex_id = try self.allocator.dupe(u8, temp_hex_id);
                return hex_id;
            }
            // Otherwise loop and try another random ID
        }
    }

    /// On the caller to free the memory
    pub fn generateSessionId(self: *App) ![]const u8 {
        var prng = std.crypto.random;
        var buf: [16]u8 = undefined;

        while (true) {
            // Generate a random 64-bit session ID
            const new_id = prng.int(usize);
            const temp_hex_id = try std.fmt.bufPrint(&buf, "{x:0>16}", .{new_id});

            // Check if this ID already exists
            var stmt = try self.main_db.prepare("SELECT session_id FROM sessions WHERE session_id = ?");
            defer stmt.deinit();

            const exists = try stmt.one(usize, .{}, .{ .session_id = temp_hex_id });

            // If ID doesn't exist, we can use it
            if (exists == null) {
                // Allocate memory for the final hex_id
                const hex_id = try self.allocator.dupe(u8, temp_hex_id);
                return hex_id;
            }
            // Otherwise loop and try another random ID
        }
    }

    /// On the caller to free the memory
    pub fn retrievePasswordHashFromUserId(self: *App, user_id: []const u8) !?[]const u8 {
        var stmt = try self.main_db.prepare("SELECT password FROM users WHERE user_id = ?");
        defer stmt.deinit();

        return stmt.oneAlloc([]const u8, self.allocator.*, .{}, .{
            .user_id = user_id,
        });
    }

    /// On the caller to free the memory
    pub fn retrieveUserIdFromUsername(self: *App, username: []const u8) !?[]const u8 {
        var stmt = try self.main_db.prepare("SELECT user_id FROM users WHERE username = ?");
        defer stmt.deinit();

        return stmt.oneAlloc([]const u8, self.allocator.*, .{}, .{
            .username = username,
        });
    }

    /// On the caller to free the memory
    pub fn retrieveUserIdFromSessionId(self: *App, session_id: []const u8) !?[]const u8 {
        var stmt = try self.main_db.prepare("SELECT user_id FROM sessions WHERE session_id = ?");
        defer stmt.deinit();

        return stmt.oneAlloc([]const u8, self.allocator.*, .{}, .{
            .session_id = session_id,
        });
    }

    /// On the caller to free the memory
    pub fn retrieveSessionIdFromUserId(self: *App, user_id: []const u8) !?[]const u8 {
        var stmt = try self.main_db.prepare("SELECT session_id FROM sessions WHERE user_id = ?");
        defer stmt.deinit();

        return stmt.oneAlloc([]const u8, self.allocator.*, .{}, .{
            .user_id = user_id,
        });
    }

    pub fn cleanupExpiredSessions(self: *App) !void {
        // Delete sessions that are older than 1 hour (3600 seconds)
        var stmt = try self.main_db.prepare("DELETE FROM sessions WHERE created_at < datetime('now', '-1 hour')");
        defer stmt.deinit();

        try stmt.exec(.{}, .{});
    }
};

/// On the caller to free the memory
pub fn createSession(app: *App, user_id: []const u8) ![]const u8 {
    const session_id = try app.generateSessionId();

    var stmt = try app.main_db.prepare("INSERT INTO sessions (user_id, session_id, created_at) VALUES (?, ?, CURRENT_TIMESTAMP)");
    defer stmt.deinit();

    try stmt.exec(.{}, .{ .user_id = user_id, .session_id = session_id });

    // Return a new allocation that the caller owns
    return session_id;
}

/// On the caller to free the memory
pub fn createUser(app: *App, username: []const u8, password: []const u8) ![]const u8 {
    const hash: []u8 = try app.allocator.alloc(u8, 116); // I'm not quite certain how this can be changed, but the hash generated is 116 bytes
    defer app.allocator.free(hash);

    const params: std.crypto.pwhash.argon2.Params = .{ .t = 2, .m = 1000, .p = 1 };
    const options: std.crypto.pwhash.argon2.HashOptions = .{ .allocator = app.allocator.*, .encoding = .phc, .mode = .argon2i, .params = params };

    _ = try std.crypto.pwhash.argon2.strHash(password, options, hash);

    const user_id = try app.generateUserId();

    var stmt = try app.main_db.prepare("INSERT INTO users (username, password, user_id) VALUES (?, ?, ?)");
    defer stmt.deinit();

    try stmt.exec(.{}, .{ .username = username, .password = hash, .user_id = user_id });

    return user_id;
}