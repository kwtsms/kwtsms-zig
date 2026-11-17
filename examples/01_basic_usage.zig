const std = @import("std");
const kwtsms = @import("kwtsms");

// 2026-11-15 16:52 +03: main takes Init.Minimal to get the process environment for fromEnv, zig-017-port
pub fn main(init: std.process.Init.Minimal) !void {
    const allocator = std.heap.page_allocator;

    // Create client from environment variables / .env file
    var client = try kwtsms.KwtSMS.fromEnv(allocator, init.environ, null);

    // Verify credentials
    const verify_result = try client.verify();
    if (verify_result.ok) {
        std.debug.print("Connected. Balance: {d:.2}\n", .{verify_result.balance.?});
    } else {
        std.debug.print("Verification failed: {s}\n", .{verify_result.err.?});
        return;
    }

    // Send SMS
    const resp = try client.sendOne("965XXXXXXXX", "Hello from kwtsms-zig!", null);
    if (resp.isOk()) {
        std.debug.print("Sent. msg-id: {s}, balance: {d:.2}\n", .{
            resp.msg_id.?,
            resp.balance_after.?,
        });
    } else {
        std.debug.print("Error: {s}\n", .{resp.description.?});
        if (resp.action) |action| {
            std.debug.print("Action: {s}\n", .{action});
        }
    }
}
