const std = @import("std");

pub const Env = struct {
    env_path: []const u8,

    pub fn get_var(self: *const Env, allocator: std.mem.Allocator, key: []const u8) !?[:0]const u8 {
        var file = try std.fs.openFileAbsolute(self.env_path, .{});
        defer file.close();

        var buff: [1024]u8 = undefined; // env file shouldn't be larger than 1024 characters
        const bytes_read: usize = try file.readAll(&buff); // Read everything into the buffer
        const content = buff[0..bytes_read];

        var it = std.mem.splitScalar(u8, content, '\n');
        while (it.next()) |line| {
            var kv = std.mem.splitScalar(u8, line, '=');
            if (kv.next()) |parsed_key| {
                if (std.mem.eql(u8, key, parsed_key)) {
                    if (kv.next()) |parsed_value| {
                        return try allocator.dupeZ(u8, parsed_value);
                    }
                }
            }
        }

        return null;
    }
};
