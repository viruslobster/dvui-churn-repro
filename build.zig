const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const dvui = b.dependency("dvui", .{
        .target = target,
        .optimize = optimize,
        .backend = .sdl3,
        .freetype = false,
        .@"tree-sitter" = false,
        .@"tiny-file-dialogs" = false,
        .tvg = false,
    });
    const exe = b.addExecutable(.{
        .name = "dvui-churn-repro",
        .root_module = b.createModule(.{
            .root_source_file = b.path("repro.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "dvui", .module = dvui.module("dvui_sdl3") },
                .{ .name = "sdl-backend", .module = dvui.module("sdl3") },
            },
        }),
    });
    b.installArtifact(exe);
    const run = b.addRunArtifact(exe);
    b.step("run", "Open a window and log backing allocations").dependOn(&run.step);
}
