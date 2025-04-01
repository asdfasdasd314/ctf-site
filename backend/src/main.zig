const std = @import("std");
const sqlite = @import("sqlite");
const httpz = @import("httpz");
const env_zig = @import("env.zig");
const user_auth = @import("user_auth.zig");
const App = @import("app.zig").App;
const Allocator = std.mem.Allocator;

const PORT = 8080;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const env = env_zig.Env{ .env_path = "/Users/jameshollingsworth/Projects/ctf-site/backend/.env" };
    const optn = try env.get_var(allocator, "DATABASE_PATH");
    const path: [:0]const u8 = optn.?;
    defer allocator.free(path);

    var db = try sqlite.Db.init(.{
        .mode = sqlite.Db.Mode{ .File = path },
        .open_flags = .{
            .write = true,
            .create = true,
        },
    });

    var app = App{
        .allocator = &allocator,
        .db = &db,
    };

    var server = try httpz.Server(*App).init(allocator, .{ .port = PORT }, &app);
    var router = try server.router(.{});

    router.post("/api/login", user_auth.login, .{});
    router.get("/api/validate-session", user_auth.validateSession, .{});
    router.post("/api/logout", user_auth.logout, .{});
    router.post("/api/sign-up", user_auth.signup, .{});
    router.post("/api/delete-account", user_auth.deleteAccount, .{});

    std.debug.print("Listening on port {}\n", .{PORT});
    try server.listen();
}
