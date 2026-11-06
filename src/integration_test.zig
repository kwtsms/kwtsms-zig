const std = @import("std");
const kwtsms = @import("kwtsms");

// Integration tests: hit the live kwtSMS API with test_mode=true.
// Skipped if ZIG_USERNAME / ZIG_PASSWORD are not set.
// Run with: zig build test-integration

fn getTestCredentials() ?struct { username: []const u8, password: []const u8 } {
    const username = std.posix.getenv("ZIG_USERNAME") orelse return null;
    const password = std.posix.getenv("ZIG_PASSWORD") orelse return null;
    if (username.len == 0 or password.len == 0) return null;
    return .{ .username = username, .password = password };
}

// 2026-11-05 08:52 +03: live sends go only to KWTSMS_TEST_NUMBER, read through
// test_number.zig (skipped when unset); format variants are built at runtime and the
// number is never printed. The two live 250-number bulk tests (generated number
// ranges) were removed: batching has no offline seam to test it, int-testnumber.
const tn = @import("test_number");

test "integration: verify with valid credentials" {
    const creds = getTestCredentials() orelse return; // skip
    const allocator = std.heap.page_allocator;
    var client = kwtsms.KwtSMS.init(allocator, creds.username, creds.password, null, true, "");
    const result = try client.verify();
    try std.testing.expect(result.ok);
    try std.testing.expect(result.balance != null);
    try std.testing.expect(result.balance.? >= 0);
}

// 2026-11-07 00:03 +03: wrong-credential test mocked; live failed logins trip the security log (task neg-auth-tests).
// "integration: verify with wrong credentials" removed: ERR003 handling is covered offline by
// "parseResponse: parses ERROR response with enrichment" (src/request.zig) and "getAction returns
// action for known codes" (src/errors.zig).

test "integration: balance returns a number" {
    const creds = getTestCredentials() orelse return;
    const allocator = std.heap.page_allocator;
    var client = kwtsms.KwtSMS.init(allocator, creds.username, creds.password, null, true, "");
    const bal = try client.balance();
    try std.testing.expect(bal != null);
    try std.testing.expect(bal.? >= 0);
}

test "integration: send to valid Kuwait number (test mode)" {
    const creds = getTestCredentials() orelse return;
    const allocator = std.heap.page_allocator;
    var client = kwtsms.KwtSMS.init(allocator, creds.username, creds.password, null, true, "");
    const n = try tn.get(allocator);
    const resp = try client.sendOne(n, "Test from kwtsms-zig integration test", null);
    // In test mode, API should accept the message
    // It may return OK or an error depending on the sender ID and number
    try std.testing.expect(resp.result.len > 0);
}

test "integration: send rejects email input" {
    const creds = getTestCredentials() orelse return;
    const allocator = std.heap.page_allocator;
    var client = kwtsms.KwtSMS.init(allocator, creds.username, creds.password, null, true, "");
    const resp = try client.sendOne("user@example.com", "Test", null);
    try std.testing.expect(resp.isError());
}

test "integration: send rejects too-short number" {
    const creds = getTestCredentials() orelse return;
    const allocator = std.heap.page_allocator;
    var client = kwtsms.KwtSMS.init(allocator, creds.username, creds.password, null, true, "");
    const resp = try client.sendOne("123", "Test", null);
    try std.testing.expect(resp.isError());
}

test "integration: send handles + prefix normalization" {
    const creds = getTestCredentials() orelse return;
    const allocator = std.heap.page_allocator;
    var client = kwtsms.KwtSMS.init(allocator, creds.username, creds.password, null, true, "");
    const n = try tn.get(allocator);
    const resp = try client.sendOne(try tn.withPrefix(allocator, "+", n), "Normalization test", null);
    try std.testing.expect(resp.result.len > 0);
}

test "integration: send handles 00 prefix normalization" {
    const creds = getTestCredentials() orelse return;
    const allocator = std.heap.page_allocator;
    var client = kwtsms.KwtSMS.init(allocator, creds.username, creds.password, null, true, "");
    const n = try tn.get(allocator);
    const resp = try client.sendOne(try tn.withPrefix(allocator, "00", n), "Normalization test", null);
    try std.testing.expect(resp.result.len > 0);
}

test "integration: senderids returns a response" {
    const creds = getTestCredentials() orelse return;
    const allocator = std.heap.page_allocator;
    var client = kwtsms.KwtSMS.init(allocator, creds.username, creds.password, null, true, "");
    const resp = try client.senderids();
    try std.testing.expect(resp.result.len > 0);
}

test "integration: coverage returns a response" {
    const creds = getTestCredentials() orelse return;
    const allocator = std.heap.page_allocator;
    var client = kwtsms.KwtSMS.init(allocator, creds.username, creds.password, null, true, "");
    const resp = try client.coverage();
    try std.testing.expect(resp.result.len > 0);
}

test "integration: emoji-only message returns error" {
    const creds = getTestCredentials() orelse return;
    const allocator = std.heap.page_allocator;
    var client = kwtsms.KwtSMS.init(allocator, creds.username, creds.password, null, true, "");
    const n = try tn.get(allocator);
    const resp = try client.sendOne(n, "\xF0\x9F\x98\x80\xF0\x9F\x98\x82", null);
    try std.testing.expect(resp.isError());
    try std.testing.expectEqualStrings("ERR009", resp.code.?);
}

test "integration: send handles Arabic-Indic digit phone number" {
    const creds = getTestCredentials() orelse return;
    const allocator = std.heap.page_allocator;
    var client = kwtsms.KwtSMS.init(allocator, creds.username, creds.password, null, true, "");
    const n = try tn.get(allocator);
    const resp = try client.sendOne(try tn.toArabicIndic(allocator, n), "Arabic numeral test", null);
    try std.testing.expect(resp.result.len > 0);
}

test "integration: send handles Extended Arabic-Indic (Persian) digit phone number" {
    const creds = getTestCredentials() orelse return;
    const allocator = std.heap.page_allocator;
    var client = kwtsms.KwtSMS.init(allocator, creds.username, creds.password, null, true, "");
    const n = try tn.get(allocator);
    const resp = try client.sendOne(try tn.toPersian(allocator, n), "Persian numeral test", null);
    try std.testing.expect(resp.result.len > 0);
}

test "integration: send handles mixed Arabic-Indic and Latin digits" {
    const creds = getTestCredentials() orelse return;
    const allocator = std.heap.page_allocator;
    var client = kwtsms.KwtSMS.init(allocator, creds.username, creds.password, null, true, "");
    const n = try tn.get(allocator);
    // First and last 3 digits Arabic-Indic, the middle Latin.
    const resp = try client.sendOne(try tn.toMixedArabicLatin(allocator, n), "Mixed numeral test", null);
    try std.testing.expect(resp.result.len > 0);
}

test "integration: duplicate numbers deduplicated" {
    const creds = getTestCredentials() orelse return;
    const allocator = std.heap.page_allocator;
    var client = kwtsms.KwtSMS.init(allocator, creds.username, creds.password, null, true, "");
    const n = try tn.get(allocator);
    const mobiles = [_][]const u8{ try tn.withPrefix(allocator, "+", n), try tn.withPrefix(allocator, "00", n), n };
    const resp = try client.send(&mobiles, "Dedup test", null);
    // All three normalize to the same number, should send only once
    try std.testing.expect(resp.result.len > 0);
    if (resp.numbers) |count| {
        try std.testing.expectEqual(@as(i64, 1), count);
    }
}
