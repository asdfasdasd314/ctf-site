const std = @import("std");
const httpz = @import("httpz");
const App = @import("app.zig").App;

fn getMimeType(path: []const u8) []const u8 {
    if (std.mem.endsWith(u8, path, ".html")) return "text/html";
    if (std.mem.endsWith(u8, path, ".css")) return "text/css";
    if (std.mem.endsWith(u8, path, ".js")) return "application/javascript";
    if (std.mem.endsWith(u8, path, ".png")) return "image/png";
    if (std.mem.endsWith(u8, path, ".svg")) return "image/svg+xml";
    if (std.mem.endsWith(u8, path, ".json")) return "application/json";
    return "application/octet-stream";
}

pub fn serveStaticFile(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    // Handle root path
    if (std.mem.eql(u8, req.url.path, "/")) {
        req.url.path = "/index.html";
    }

    // Also attempt to serve html files if only the name is passed
    // First remove the last character if it's a /
    if (req.url.path.len > 0 and req.url.path[req.url.path.len - 1] == '/') {
        req.url.path = req.url.path[0 .. req.url.path.len - 1];
    }

    // Handle static assets - if the path contains any static asset paths, strip everything before it
    var path = req.url.path;
    const static_prefixes = [_][]const u8{ "/_app", "/assets", "/flag.png" };
    for (static_prefixes) |prefix| {
        if (std.mem.indexOf(u8, path, prefix)) |index| {
            // For flag.png, we want to serve it directly from the root
            if (std.mem.eql(u8, prefix, "/flag.png")) {
                path = "flag.png";
            } else {
                path = path[index + 1..];
            }
            break;
        }
    }

    // First try to find an HTML file with the same name as the path
    if (!std.mem.endsWith(u8, path, ".html")) {
        const html_file_path = try std.fmt.allocPrint(app.allocator.*, "build/{s}.html", .{path});
        defer app.allocator.free(html_file_path);

        if (std.fs.cwd().openFile(html_file_path, .{})) |file| {
            defer file.close();
            const stat = try file.stat();
            const buffer = try app.allocator.alloc(u8, stat.size);
            defer app.allocator.free(buffer);
            _ = try file.readAll(buffer);

            res.header("Content-Type", "text/html");
            res.status = 200;
            var writer = res.writer();
            writer.writeAll(buffer) catch unreachable;
            return;
        } else |_| {
            // If no HTML file found, continue with normal file serving
        }
    }

    // Use the path, else send a 404
    const file_path = try std.fmt.allocPrint(app.allocator.*, "build/{s}", .{path});
    defer app.allocator.free(file_path);
    const file = std.fs.cwd().openFile(file_path, .{}) catch {
        res.status = 404;
        res.body = "404 Not Found";
        return;
    };
    defer file.close();

    // Create a fixed buffer to read the file into
    const stat = try file.stat();
    const buffer = try app.allocator.alloc(u8, stat.size);
    defer app.allocator.free(buffer);
    _ = try file.readAll(buffer);

    res.header("Content-Type", getMimeType(path));

    // Set the response body to the slice of the buffer that was actually read
    res.status = 200;
    var writer = res.writer();
    writer.writeAll(buffer) catch unreachable;
}
