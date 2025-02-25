const std = @import("std");
const httpz = @import("httpz");
const buff_override = @import("buffer_override.zig");
const Allocator = std.mem.Allocator;

const PORT = 8080;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var server = try httpz.Server().init(allocator, .{
        .port = PORT,
    });

    defer server.deinit();

    const router = server.router();
    router.get("/", index);
    router.get("/api/buffer-override/get-buffers", buff_override.get_buffers);
    router.post("/api/buffer-override/set-buffer1", buff_override.set_buffer1);
    router.put("/api/buffer-override/setup", buff_override.setup);
    router.put("/api/buffer-override/exit", buff_override.exit);
    std.debug.print("Server running at port {d}", .{PORT});
    try server.listen();
}

fn index(_: *httpz.Request, res: *httpz.Response) !void {
    res.body =
        \\Hello World
    ;
}
