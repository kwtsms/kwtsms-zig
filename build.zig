const std = @import("std");

// 2026-11-15 16:46 +03: ported to the Zig 0.17 build API (addLibrary/addTest/addExecutable take
// root_module = b.createModule(...); version now comes from @import("build.zig.zon")), zig-017-port.
const zon = @import("build.zig.zon");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 2026-11-05 08:52 +03: test-only helper for the KWTSMS_TEST_NUMBER phone number, a module
    // of its own so the unit tests (module kwtsms) and the integration tests (module root) share
    // one file; Zig rejects one file in two modules. Only test blocks import it, int-testnumber.
    const test_number_mod = b.createModule(.{
        .root_source_file = b.path("src/test_number.zig"),
    });

    // 2026-11-05 14:24 +03: the library version for the User-Agent comes from build.zig.zon, never a
    // hand-typed constant (#939).
    // 2026-11-15 16:46 +03: read via @import("build.zig.zon") (supported since 0.14) instead of parsing the
    // file text with b.build_root (removed), zig-017-port.
    const build_options = b.addOptions();
    build_options.addOption([]const u8, "version", zon.version);
    const build_options_mod = build_options.createModule();

    // Library module (for consumers via build.zig.zon)
    const kwtsms_mod = b.addModule("kwtsms", .{
        .root_source_file = b.path("src/kwtsms.zig"),
        .target = target,
        .optimize = optimize,
    });
    kwtsms_mod.addImport("test_number", test_number_mod);
    kwtsms_mod.addImport("build_options", build_options_mod);

    // Static library
    // 2026-11-15 16:46 +03: addStaticLibrary removed; addLibrary(.linkage = .static) with its own module, zig-017-port.
    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/kwtsms.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib_mod.addImport("test_number", test_number_mod);
    lib_mod.addImport("build_options", build_options_mod);
    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "kwtsms",
        .root_module = lib_mod,
    });
    b.installArtifact(lib);

    // Unit tests (library)
    // 2026-11-15 16:46 +03: addTest takes root_module now, zig-017-port.
    const unit_mod = b.createModule(.{
        .root_source_file = b.path("src/kwtsms.zig"),
        .target = target,
        .optimize = optimize,
    });
    unit_mod.addImport("test_number", test_number_mod);
    unit_mod.addImport("build_options", build_options_mod);
    const lib_unit_tests = b.addTest(.{ .root_module = unit_mod });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    // Integration tests (separate step, requires credentials)
    const int_mod = b.createModule(.{
        .root_source_file = b.path("src/integration_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    int_mod.addImport("kwtsms", kwtsms_mod);
    int_mod.addImport("test_number", test_number_mod);
    const integration_tests = b.addTest(.{ .root_module = int_mod });
    const run_integration_tests = b.addRunArtifact(integration_tests);

    const integration_step = b.step("test-integration", "Run integration tests (requires ZIG_USERNAME/ZIG_PASSWORD)");
    integration_step.dependOn(&run_integration_tests.step);

    // Examples
    const examples = [_]struct { name: []const u8, src: []const u8 }{
        .{ .name = "example-00", .src = "examples/00_raw_api.zig" },
        .{ .name = "example-01", .src = "examples/01_basic_usage.zig" },
        .{ .name = "example-02", .src = "examples/02_otp_flow.zig" },
        .{ .name = "example-03", .src = "examples/03_bulk_sms.zig" },
        .{ .name = "example-04", .src = "examples/04_error_handling.zig" },
        .{ .name = "example-05", .src = "examples/05_otp_production.zig" },
    };

    for (examples) |ex| {
        // 2026-11-15 16:46 +03: executables take root_module too, zig-017-port.
        const ex_mod = b.createModule(.{
            .root_source_file = b.path(ex.src),
            .target = target,
            .optimize = optimize,
        });
        ex_mod.addImport("kwtsms", kwtsms_mod);
        const example = b.addExecutable(.{
            .name = ex.name,
            .root_module = ex_mod,
        });
        b.installArtifact(example);
    }
}
