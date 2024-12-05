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

    const correptio = b.addExecutable(.{
        .name = "correptio",
        .root_source_file = b.path("src/correptio.zig"),
        .target = target,
        .optimize = optimize,
    });
    correptio.linkLibC();

    b.installArtifact(correptio);
}
