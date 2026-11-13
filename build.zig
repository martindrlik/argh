const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const core_mod = b.addModule("core", .{
        .root_source_file = b.path("src/core.zig"),
        .target = target,
    });

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });

    core_mod.addImport("raylib", raylib_dep.module("raylib"));
    core_mod.linkLibrary(raylib_dep.artifact("raylib"));

    const exe = b.addExecutable(.{
        .name = "argh",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "core", .module = core_mod },
            },
        }),
    });

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    run_cmd.addPassthruArgs();

    const core_mod_tests = b.addTest(.{
        .root_module = core_mod,
    });

    const run_core_mod_tests = b.addRunArtifact(core_mod_tests);

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_core_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
}
