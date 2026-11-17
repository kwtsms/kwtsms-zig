const std = @import("std");
const kwtsms = @import("kwtsms");

// 2026-11-15 16:52 +03: main takes Init.Minimal to get the process environment for fromEnv, zig-017-port
pub fn main(init: std.process.Init.Minimal) !void {
    const allocator = std.heap.page_allocator;
    var client = try kwtsms.KwtSMS.fromEnv(allocator, init.environ, null);

    // Send to multiple numbers
    const mobiles = [_][]const u8{
        "965XXXXXXXX",
        "+96512345678",
        "0096587654321",
    };

    const resp = try client.send(&mobiles, "Bulk message from kwtsms-zig", null);
    if (resp.isOk()) {
        std.debug.print("Sent to {d} numbers. Points: {d}, Balance: {d:.2}\n", .{
            resp.numbers.?,
            resp.points_charged.?,
            resp.balance_after.?,
        });
    } else {
        std.debug.print("Error: {s}\n", .{resp.description.?});
    }
}
