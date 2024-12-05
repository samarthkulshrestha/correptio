const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const debuggee = b.addExecutable(.{
        .name = "debuggee",
        .root_source_file = b.path("src/debuggee.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(debuggee);

    const debugger = b.addExecutable(.{
        .name = "debugger",
        .root_source_file = b.path("src/debugger.zig"),
        .target = target,
        .optimize = optimize,
    });
    debugger.linkLibC();

    b.installArtifact(debugger);
}
