const std = @import("std");
const dvui = @import("dvui");
const SDLBackend = @import("sdl-backend");

pub const std_options: std.Options = .{
    .logFn = log,
};

fn log(
    comptime level: std.log.Level,
    comptime scope: @EnumLiteral(),
    comptime format: []const u8,
    args: anytype,
) void {
    const unix_timestamp = std.Io.Clock.real.now(std.Options.debug_io).toSeconds();
    std.log.defaultLog(level, scope, "[{d}] " ++ format, .{unix_timestamp} ++ args);
}

pub fn main(init: std.process.Init) !void {
    dvui.io = init.io;
    var gpa: std.heap.DebugAllocator(.{ .verbose_log = true }) = .init;
    defer std.debug.assert(gpa.deinit() == .ok);

    var backend = try SDLBackend.initWindow(.{
        .io = init.io,
        .size = .{ .w = 480, .h = 160 },
        .vsync = false,
        .title = "dvui arena churn repro",
    });
    defer backend.deinit();

    var open = true;
    var win = try dvui.Window.init(@src(), gpa.allocator(), backend.backend(), .{
        .open_flag = &open,
    });
    defer win.deinit();

    var frame: usize = 0;
    while (open) : (frame += 1) {
        try win.begin(win.beginWait(false));
        try backend.addAllEvents(&win);
        dvui.label(@src(), "An unchanging label", .{}, .{});
        _ = try win.end(.{});
    }
}
