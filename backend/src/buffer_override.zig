const std = @import("std");
const httpz = @import("httpz");

// Define at this level so we can free in the 'exit' function
var allocator = std.heap.page_allocator;

var large_buff: []u8 = undefined;
var buffer1: []u8 = undefined;
var buffer2: []u8 = undefined;
var freed: bool = true;

pub fn setup(_: *httpz.Request, _: *httpz.Response) !void {
    if (!freed) { // to prevent memory leaks
        return;
    }

    large_buff = try allocator.alloc(u8, 32); // Do this to create a small buffer between them so typos or whatnot doesn't immediately break it, have to work a little harder
    buffer1 = large_buff[0..16];
    buffer2 = large_buff[16..32];

    freed = false;

    std.mem.copyForwards(u8, buffer1, "Buffer1         "); // To prevent typos or whatever
    std.mem.copyForwards(u8, buffer2, "Unbreakable!    ");
}

pub fn get_buffers(_: *httpz.Request, res: *httpz.Response) !void {
    if (freed) { // to prevent use-after-frees
        return;
    }

    // As we it's undefined behavior to validate if the buffers have been initialized, and this is a development environment where a database will replace inlining the buffers, this is fine
    try res.json(.{ .buffer1 = buffer1, .buffer2 = buffer2, .ptr1 = @intFromPtr(buffer1.ptr), .ptr2 = @intFromPtr(buffer2.ptr) }, .{});
}

pub fn set_buffer1(req: *httpz.Request, _: *httpz.Response) !void {
    if (freed) { // to prevent use-after-free
        return;
    }

    const query = try req.query();

    var new_content = query.get("buff").?;

    // Perform some basic bounds checks, as if it's millions of characters or something that's just terrible to try to allocate that much for one process
    if (new_content.len > 32) {
        new_content = new_content[0..32];
    }

    var buff_slice = buffer1.ptr[0..buffer1.len];
    for (0..buffer1.len) |i| {
        buff_slice[i] = " "[0];
    }

    var slice = buffer1.ptr[0..new_content.len];
    for (0..new_content.len) |i| {
        slice[i] = new_content[i];
    }
}

// Used to free memory
pub fn exit(_: *httpz.Request, _: *httpz.Response) !void {
    if (!freed) { // To prevent double free
        freed = true;
        allocator.free(large_buff);
    }
}
