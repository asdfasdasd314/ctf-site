const std = @import("std");
const sqlite = @import("sqlite");
const httpz = @import("httpz");
const env_zig = @import("env.zig");
const user_auth = @import("user_auth.zig");
const App = @import("app.zig").App;
const vuln_auth_exercise = @import("exercises/vulnerable_auth.zig");
const exercise = @import("exercises/exercise.zig");
const RateLimitter = @import("rate_limitter.zig").RateLimitter;
const RateCount = @import("rate_limitter.zig").RateCount;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const result = gpa.deinit();
        if (result == .leak) {
            std.log.warn("Memory leaks detected\n", .{});
        }
    }
    const allocator = gpa.allocator();

    const env = env_zig.Env{ .env_path = "/Users/jameshollingsworth/Projects/ctf-site/backend/.env" };

    const port_opt = try env.get_var(allocator, "PORT");
    const port = std.fmt.parseInt(u16, port_opt.?, 10) catch 8080;

    const main_db_opt = try env.get_var(allocator, "MAIN_DB_PATH");
    const main_db_path: [:0]const u8 = main_db_opt.?;
    defer allocator.free(main_db_path);

    var main_db = try sqlite.Db.init(.{
        .mode = sqlite.Db.Mode{ .File = main_db_path },
        .open_flags = .{
            .write = true,
            .create = true,
        },
    });

    const vuln_auth_db_opt = try env.get_var(allocator, "VULN_AUTH_DB_PATH");
    const vuln_auth_db_path: [:0]const u8 = vuln_auth_db_opt.?;
    defer allocator.free(vuln_auth_db_path);
    var vuln_auth_db = try sqlite.Db.init(.{
        .mode = sqlite.Db.Mode{ .File = vuln_auth_db_path },
        .open_flags = .{
            .write = true,
            .create = true,
        },
    });

    var vuln_auth = vuln_auth_exercise.VulnerableAuth.init(&vuln_auth_db, &allocator);
    var app = App.init(&allocator, &main_db, &vuln_auth);

    var server = try httpz.Server(*App).init(allocator, .{ .port = port }, &app);
    defer server.deinit();

    var ip_addresses = std.AutoHashMap(u32, RateCount).init(allocator);
    defer ip_addresses.deinit();

    // Create different rate limiters for different endpoints
    const default_rate_limitter = try server.middleware(RateLimitter, .{ .ip_addresses = &ip_addresses, .max_requests = 200, .reset_interval = 60 });

    const sensitive_rate_limitter = try server.middleware(RateLimitter, .{ .ip_addresses = &ip_addresses, .max_requests = 100, .reset_interval = 60, .path = "/api/exercises" });

    var router = try server.router(.{});
    router.middlewares = &.{default_rate_limitter};

    // Main app
    router.post("/api/login", user_auth.login, .{ .middlewares = &.{sensitive_rate_limitter} });
    router.get("/api/validate-session", user_auth.validateSession, .{});
    router.post("/api/logout", user_auth.logout, .{});
    router.post("/api/sign-up", user_auth.signup, .{ .middlewares = &.{sensitive_rate_limitter} });
    router.post("/api/delete-account", user_auth.deleteAccount, .{ .middlewares = &.{sensitive_rate_limitter} });

    // User Info
    router.get("/api/user/creation-date", user_auth.getUserCreationDate, .{});

    // Exercises
    router.get("/api/exercises", exercise.retrieveAllExerciseData, .{ .middlewares = &.{sensitive_rate_limitter} });
    router.get("/api/exercises/completed", exercise.getCompletedExercises, .{ .middlewares = &.{sensitive_rate_limitter} });
    router.post("/api/exercises/validate-flag", exercise.validateFlag, .{ .middlewares = &.{sensitive_rate_limitter} });
    router.post("/api/exercises/check-solved", exercise.checkSolved, .{});

    // Vulnerable User Authentication Exercise
    router.post("/api/exercises/1/vulnerable-login", vuln_auth_exercise.vulnerableLogin, .{ .middlewares = &.{sensitive_rate_limitter} });
    router.post("/api/exercises/1/vulnerable-signup", vuln_auth_exercise.vulnerableSignup, .{ .middlewares = &.{sensitive_rate_limitter} });
    router.post("/api/exercises/1/vulnerable-retrieve-user-data", vuln_auth_exercise.vulnerableRetrieveUserData, .{ .middlewares = &.{sensitive_rate_limitter} });

    std.debug.print("Listening on port {}\n", .{port});
    try server.listen();
}
