const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "main",
        .root_source_file = b.path("src/main.zig"),
        .target = b.host,
    });

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_exe.addArgs(args);
    }

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);


    // tests
    // const test_step = b.step("test", "Run unit tests");
    // const unit_tests = b.addTest(.{
    //     .root_source_file = "./src/main.zig",
    //     .target = b.resolveTargetQuery(.{})
    // });
    // const run_unit_tests = b.addRunArtifact(unit_tests);
    // test_step.dependOn(&run_unit_tests.step);
}