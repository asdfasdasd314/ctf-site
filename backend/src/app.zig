const sqlite = @import("sqlite");
const std = @import("std");
const vuln_auth_exercise = @import("exercises/vulnerable_auth.zig");
const exercise = @import("exercises/exercise.zig");
const ExposedExercise = exercise.ExposedExercise;

pub const App = struct {
    allocator: *const std.mem.Allocator,
    main_db: *sqlite.Db,
    vuln_auth_exercise: *vuln_auth_exercise.VulnerableAuth,

    pub fn init(allocator: *const std.mem.Allocator, main_db: *sqlite.Db, vuln_auth: *vuln_auth_exercise.VulnerableAuth) !App {
        return App{ .allocator = allocator, .main_db = main_db, .vuln_auth_exercise = vuln_auth };
    }

    pub fn deinit(self: *App) void {
        self.vuln_auth_exercise.deinit();
        self.allocator.destroy(self.vuln_auth_exercise);
    }

    pub fn checkPassword(self: *App, user_id: []const u8, pw: []const u8) !bool {
        // First get the salt for this user
        var stmt1 = try self.main_db.prepare("SELECT salt FROM users WHERE user_id = ?");
        defer stmt1.deinit();

        const salt_opt = try stmt1.oneAlloc([]const u8, self.allocator.*, .{}, .{ .user_id = user_id });
        if (salt_opt) |salt| {
            defer self.allocator.free(salt);

            // Get the stored hash
            const hash_opt = try self.retrievePasswordHashFromUserId(user_id);
            if (hash_opt) |hash| {
                defer self.allocator.free(hash);

                // Hash the provided password with the salt
                const key: []u8 = try self.allocator.alloc(u8, 16);
                defer self.allocator.free(key);

                const params: std.crypto.pwhash.argon2.Params = .{
                    .t = 2,
                    .m = 1000,
                    .p = 1,
                };

                try std.crypto.pwhash.argon2.kdf(self.allocator.*, key, pw, salt, params, .argon2i);

                // Compare the hashes
                const options: std.crypto.pwhash.argon2.VerifyOptions = .{ .allocator = self.allocator.* };
                std.crypto.pwhash.argon2.strVerify(hash, key, options) catch |err| switch (err) {
                    std.crypto.pwhash.HasherError.PasswordVerificationFailed => {
                        return false;
                    },
                    else => {
                        return err;
                    },
                };
                return true;
            }
        }
        return false;
    }

    pub fn generateRandom64BitString(self: *App, comptime table_name: []const u8, comptime column_name: []const u8) ![]const u8 {
        var prng = std.crypto.random;
        var buf: [16]u8 = undefined;

        while (true) {
            // Generate a random 64-bit string
            const new_string = prng.int(usize);
            const temp_hex_string = try std.fmt.bufPrint(&buf, "{x:0>16}", .{new_string});

            // Check if this string already exists
            const query = std.fmt.comptimePrint("SELECT COUNT(*) FROM {s} WHERE {s} = ?", .{ table_name, column_name });
            var stmt = try self.main_db.prepare(query);
            defer stmt.deinit();

            const exists = try stmt.one(usize, .{}, .{ .column_name = temp_hex_string });

            // If string doesn't exist, we can use it
            if (exists == 0) {
                // Allocate memory for the final hex_string
                const hex_string = try self.allocator.dupe(u8, temp_hex_string);
                return hex_string;
            }
            // Otherwise loop and try another random string
        }
    }

    /// On the caller to free the memory
    pub fn generateUserId(self: *App) ![]const u8 {
        return try self.generateRandom64BitString("users", "user_id");
    }

    /// On the caller to free the memory
    pub fn generateSessionId(self: *App) ![]const u8 {
        return try self.generateRandom64BitString("sessions", "session_id");
    }

    /// On the caller to free the memory
    pub fn generateSalt(self: *App) ![]const u8 {
        return try self.generateRandom64BitString("users", "salt");
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

    /// Returns a list of exercise IDs that the user has completed
    /// On the caller to free the memory
    pub fn getCompletedExercises(self: *App, user_id: []const u8) ![]ExposedExercise {
        var stmt = try self.main_db.prepare(
            \\ SELECT
            \\     e.exercise_id,
            \\     e.category,
            \\     e.title,
            \\     e.difficulty,
            \\     e.points,
            \\     e.solve_count,
            \\     e.created_at,
            \\     e.description,
            \\     e.tags
            \\ FROM exercises e
            \\ JOIN completions c ON e.exercise_id = c.exercise_id
            \\ WHERE c.user_id = ?
        );
        defer stmt.deinit();

        return stmt.all(ExposedExercise, self.allocator.*, .{}, .{user_id});
    }

    /// On the caller to free the memory
    pub fn getUserCreationDate(self: *App, user_id: []const u8) !?[]const u8 {
        var stmt = try self.main_db.prepare("SELECT created_at FROM users WHERE user_id = ?");
        defer stmt.deinit();

        return stmt.oneAlloc([]const u8, self.allocator.*, .{}, .{user_id});
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

    const key: []u8 = try app.allocator.alloc(u8, 16);
    defer app.allocator.free(key);

    const salt = try app.generateSalt();
    defer app.allocator.free(salt);

    const params: std.crypto.pwhash.argon2.Params = .{
        .t = 2,
        .m = 1000,
        .p = 1,
    };

    const options: std.crypto.pwhash.argon2.HashOptions = .{
        .allocator = app.allocator.*,
        .encoding = .phc,
        .mode = .argon2i,
        .params = params,
    };

    // We generate a key of 16 bytes that also encodes a salt to prevent rainbow table attacks
    try std.crypto.pwhash.argon2.kdf(app.allocator.*, key, password, salt, params, .argon2i);

    _ = try std.crypto.pwhash.argon2.strHash(key, options, hash);

    const user_id = try app.generateUserId();

    var stmt1 = try app.main_db.prepare("INSERT INTO users (username, password, salt, user_id) VALUES (?, ?, ?, ?)");
    defer stmt1.deinit();

    try stmt1.exec(.{}, .{ .username = username, .password = hash, .salt = salt, .user_id = user_id });

    return user_id;
}
