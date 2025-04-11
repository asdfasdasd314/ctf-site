const App = @import("../app.zig").App;
const httpz = @import("httpz");
const user_auth = @import("../user_auth.zig");
const UserInfo = user_auth.UserInfo;
const std = @import("std");

pub const ExposedExercise = struct {
    exercise_id: i32,
    category: []const u8,
    title: []const u8,
    difficulty: []const u8,
    points: i32,
    solve_count: i32,
    created_at: []const u8,
    description: []const u8,
    tags: []const u8,

    pub fn deinit(self: *ExposedExercise, allocator: std.mem.Allocator) void {
        allocator.free(self.category);
        allocator.free(self.title);
        allocator.free(self.difficulty);
        allocator.free(self.created_at);
        allocator.free(self.description);
        allocator.free(self.tags);
    }
};

const ExerciseFlag = struct {
    exercise_id: i32,
    flag: []const u8,
};

const ExerciseID = struct {
    exercise_id: i32,
};

pub fn retrieveAllExerciseData(app: *App, _: *httpz.Request, res: *httpz.Response) !void {
    var stmt = try app.main_db.prepare(
        \\ SELECT
        \\     exercise_id,
        \\     category,
        \\     title,
        \\     difficulty,
        \\     points,
        \\     solve_count,
        \\     created_at,
        \\     description,
        \\     tags
        \\ FROM exercises
    );
    defer stmt.deinit();

    const exercises: []ExposedExercise = try stmt.all(ExposedExercise, app.allocator.*, .{}, .{});
    defer {
        for (exercises) |*exercise| {
            exercise.deinit(app.allocator.*);
        }
        app.allocator.free(exercises);
    }

    try res.json(.{ .success = true, .exercises = exercises }, .{});
}

pub fn validateFlag(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const session_id_opt = req.cookies().get("session_id");
    if (session_id_opt) |session_id| {
        const user_id_opt = try app.retrieveUserIdFromSessionId(session_id);
        if (user_id_opt) |user_id| {
            defer app.allocator.free(user_id);
            const body = req.body().?;
            const json = try std.json.parseFromSlice(ExerciseFlag, app.allocator.*, body, .{});
            defer json.deinit();
            const exercise_id = json.value.exercise_id;
            const flag = json.value.flag;

            var flag_stmt = try app.main_db.prepare(
                \\ SELECT
                \\     flag
                \\ FROM exercises
                \\ WHERE exercise_id = ?
            );
            defer flag_stmt.deinit();

            const flag_opt = try flag_stmt.oneAlloc([]const u8, app.allocator.*, .{}, .{exercise_id});
            if (flag_opt) |true_flag| {
                defer app.allocator.free(true_flag);

                if (std.mem.eql(u8, flag, true_flag)) {
                    // Add to completions
                    var completion_stmt = try app.main_db.prepare(
                        \\ INSERT INTO completions (user_id, exercise_id)
                        \\ VALUES (?, ?)
                    );
                    defer completion_stmt.deinit();
                    try completion_stmt.exec(.{}, .{ user_id, exercise_id });

                    // Increment number of times exercise has been solved
                    var increment_count_stmt = try app.main_db.prepare(
                        \\ UPDATE exercises
                        \\ SET solve_count = solve_count + 1
                        \\ WHERE exercise_id = ?
                    );
                    defer increment_count_stmt.deinit();
                    try increment_count_stmt.exec(.{}, .{exercise_id});

                    try res.json(.{ .success = true }, .{});
                } else {
                    try res.json(.{ .success = false, .err = "Invalid flag" }, .{});
                }
            } else {
                try res.json(.{ .success = false, .err = "Exercise not found" }, .{});
            }
        } else {
            try res.json(.{ .success = false, .err = "Not logged in" }, .{});
        }
    } else {
        try res.json(.{ .success = false, .err = "Not logged in" }, .{});
        return;
    }
}

pub fn checkSolved(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const session_id_opt = req.cookies().get("session_id");
    if (session_id_opt) |session_id| {
        const user_id_opt = try app.retrieveUserIdFromSessionId(session_id);
        if (user_id_opt) |user_id| {
            defer app.allocator.free(user_id);
            const json = try std.json.parseFromSlice(ExerciseID, app.allocator.*, req.body().?, .{});
            defer json.deinit();
            const exercise_id: i32 = json.value.exercise_id;

            var completion_stmt = try app.main_db.prepare(
                \\ SELECT
                \\     COUNT(*)
                \\ FROM completions
                \\ WHERE user_id = ? AND exercise_id = ?
            );
            defer completion_stmt.deinit();

            const completion_opt = try completion_stmt.one(i32, .{}, .{ user_id, exercise_id });
            if (completion_opt) |completion| {
                try res.json(.{ .success = true, .solved = completion > 0 }, .{});
                return;
            } else {
                try res.json(.{ .success = false, .err = "Exercise not found" }, .{});
                return;
            }
        }
    }

    try res.json(.{ .success = true, .solved = false }, .{});
}

pub fn getCompletedExercises(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const session_id_opt = req.cookies().get("session_id");
    if (session_id_opt) |session_id| {
        const user_id_opt = try app.retrieveUserIdFromSessionId(session_id);
        if (user_id_opt) |user_id| {
            defer app.allocator.free(user_id);
            const completed_exercises = try app.getCompletedExercises(user_id);
            defer {
                for (completed_exercises) |*exercise| {
                    exercise.deinit(app.allocator.*);
                }
                app.allocator.free(completed_exercises);
            }
            try res.json(.{ .success = true, .exercises = completed_exercises }, .{});
            return;
        }
    }
    try res.json(.{ .success = false, .err = "Not logged in" }, .{});
}
