const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 2026-11-05 08:52 +03: test-only helper for the KWTSMS_TEST_NUMBER phone number, a module
    // of its own so the unit tests (module kwtsms) and the integration tests (module root) share
    // one file; Zig 0.13 rejects one file in two modules. Only test blocks import it, int-testnumber.
    const test_number_mod = b.createModule(.{
        .root_source_file = b.path("src/test_number.zig"),
    });

    // Library module (for consumers via build.zig.zon)
    const kwtsms_mod = b.addModule("kwtsms", .{
        .root_source_file = b.path("src/kwtsms.zig"),
        .target = target,
        .optimize = optimize,
    });
    kwtsms_mod.addImport("test_number", test_number_mod);

    // Static library
    const lib = b.addStaticLibrary(.{
        .name = "kwtsms",
        .root_source_file = b.path("src/kwtsms.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("test_number", test_number_mod);
    b.installArtifact(lib);

    // Unit tests (library)
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/kwtsms.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib_unit_tests.root_module.addImport("test_number", test_number_mod);
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    // Integration tests (separate step, requires credentials)
    const integration_tests = b.addTest(.{
        .root_source_file = b.path("src/integration_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    integration_tests.root_module.addImport("kwtsms", kwtsms_mod);
    integration_tests.root_module.addImport("test_number", test_number_mod);
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
        const example = b.addExecutable(.{
            .name = ex.name,
            .root_source_file = b.path(ex.src),
            .target = target,
            .optimize = optimize,
        });
        example.root_module.addImport("kwtsms", kwtsms_mod);
        b.installArtifact(example);
    }
}
