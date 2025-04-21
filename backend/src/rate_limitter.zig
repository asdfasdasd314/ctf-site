const std = @import("std");
const httpz = @import("httpz");
const HashMap = std.AutoHashMap;

pub const RateCount = struct {
    count: u32,
    last_reset: i64,
};

pub const RateLimitter = struct {
    ip_addresses: *HashMap(u32, RateCount),
    max_requests: u32,
    reset_interval: i64,
    path: ?[]const u8,

    pub fn init(config: Config) !RateLimitter {
        return RateLimitter{
            .ip_addresses = config.ip_addresses,
            .max_requests = config.max_requests,
            .reset_interval = config.reset_interval,
            .path = config.path,
        };
    }

    pub fn execute(self: *const RateLimitter, req: *httpz.Request, res: *httpz.Response, executor: anytype) !void {
        // Skip rate limiting if this middleware is path-specific and doesn't match
        if (self.path) |path| {
            // Check if the patch is contained in the request path
            if (!std.mem.startsWith(u8, req.url.path, path)) {
                return executor.next();
            }
        }

        const ip = req.address.in.sa.addr;
        if (self.ip_addresses.get(ip)) |rate_count| {
            if (std.time.timestamp() - rate_count.last_reset >= self.reset_interval) {
                try self.ip_addresses.put(ip, RateCount{ .count = 0, .last_reset = std.time.timestamp() });
            }

            if (rate_count.count >= self.max_requests) {
                res.status = 429;
                res.body = "Rate limit exceeded. Please try again later.";
                return;
            }

            try self.ip_addresses.put(ip, RateCount{ .count = rate_count.count + 1, .last_reset = rate_count.last_reset });
        } else {
            try self.ip_addresses.put(ip, RateCount{ .count = 1, .last_reset = std.time.timestamp() });
        }

        return executor.next();
    }

    pub const Config = struct {
        ip_addresses: *HashMap(u32, RateCount),
        max_requests: u32,
        reset_interval: i64,
        path: ?[]const u8 = null,
    };
};
