// FILE:      src/test_number.zig
// CREATED:   2026-11-05 08:52 +03
// TASK:      int-testnumber
// AUTHOR:    M Alhassoun
// WHAT:      Test-only helper: the test phone number and its format variants.
// WHY:       Tests must not hardcode a phone number. The number comes from the
//            KWTSMS_TEST_NUMBER environment variable (an international Kuwait
//            mobile, digits only, 965XXXXXXXX); every test that needs one is
//            skipped (error.SkipZigTest) when it is unset or malformed.
// USAGE:     KWTSMS_TEST_NUMBER=965XXXXXXXX zig build test
//            const tn = @import("test_number");
//            const n = try tn.get(allocator); defer allocator.free(n);
//            CI reads the value from the repository secret of the same name.
// DEPENDS:   Zig stdlib only (std.process.getEnvVarOwned, std.fmt). build.zig
//            registers it as module "test_number" on every module that has
//            tests; only test code uses it, so it is never in the library.

const std = @import("std");

/// For values that are only passed through unchanged (request bodies, echoes).
/// 2026-11-05 08:52 +03: placeholder for pass-through fields, int-testnumber.
pub const placeholder = "965XXXXXXXX";

/// Returns KWTSMS_TEST_NUMBER (965 plus 8 digits), owned by the caller, or
/// error.SkipZigTest when it is unset or malformed. Never print the value.
/// 2026-11-05 08:52 +03: single source of the test number, int-testnumber.
pub fn get(allocator: std.mem.Allocator) ![]u8 {
    const raw = std.process.getEnvVarOwned(allocator, "KWTSMS_TEST_NUMBER") catch return error.SkipZigTest;
    defer allocator.free(raw);
    const n = std.mem.trim(u8, raw, " \t\r\n");
    if (n.len != 11 or !std.mem.startsWith(u8, n, "965")) return error.SkipZigTest;
    for (n) |c| {
        if (c < '0' or c > '9') return error.SkipZigTest;
    }
    return allocator.dupe(u8, n);
}

/// prefix ++ n, for "+965..." and "00965..." variants. Caller frees.
/// 2026-11-05 08:52 +03: format variants built at runtime, int-testnumber.
pub fn withPrefix(allocator: std.mem.Allocator, prefix: []const u8, n: []const u8) ![]u8 {
    return std.fmt.allocPrint(allocator, "{s}{s}", .{ prefix, n });
}

/// "965" ++ sep ++ first 4 ++ sep ++ last 4 local digits. Caller frees.
/// 2026-11-05 08:52 +03: spaced, dashed and dotted variants, int-testnumber.
pub fn split(allocator: std.mem.Allocator, n: []const u8, sep: []const u8) ![]u8 {
    return std.fmt.allocPrint(allocator, "{s}{s}{s}{s}{s}", .{ n[0..3], sep, n[3..7], sep, n[7..] });
}

/// Latin digits in n[start..end] become two-byte UTF-8 digits whose zero is
/// lead/zero_low (Arabic-Indic U+0660 = D9 A0, Persian U+06F0 = DB B0).
/// 2026-11-05 08:52 +03: native-digit variants, int-testnumber.
fn shiftRange(allocator: std.mem.Allocator, n: []const u8, start: usize, end: usize, lead: u8, zero_low: u8) ![]u8 {
    var out = std.ArrayList(u8).init(allocator);
    errdefer out.deinit();
    for (n, 0..) |c, i| {
        if (i >= start and i < end and c >= '0' and c <= '9') {
            try out.append(lead);
            try out.append(zero_low + (c - '0'));
        } else {
            try out.append(c);
        }
    }
    return out.toOwnedSlice();
}

/// All digits as Arabic-Indic (U+0660-0669). Caller frees.
/// 2026-11-05 08:52 +03: int-testnumber.
pub fn toArabicIndic(allocator: std.mem.Allocator, n: []const u8) ![]u8 {
    return shiftRange(allocator, n, 0, n.len, 0xD9, 0xA0);
}

/// All digits as Extended Arabic-Indic / Persian (U+06F0-06F9). Caller frees.
/// 2026-11-05 08:52 +03: int-testnumber.
pub fn toPersian(allocator: std.mem.Allocator, n: []const u8) ![]u8 {
    return shiftRange(allocator, n, 0, n.len, 0xDB, 0xB0);
}

/// First 3 and last 3 digits Arabic-Indic, the middle Latin. Caller frees.
/// 2026-11-05 08:52 +03: mixed-digit variant, int-testnumber.
pub fn toMixedArabicLatin(allocator: std.mem.Allocator, n: []const u8) ![]u8 {
    var out = std.ArrayList(u8).init(allocator);
    errdefer out.deinit();
    for (n, 0..) |c, i| {
        if ((i < 3 or i >= n.len - 3) and c >= '0' and c <= '9') {
            try out.append(0xD9);
            try out.append(0xA0 + (c - '0'));
        } else {
            try out.append(c);
        }
    }
    return out.toOwnedSlice();
}
