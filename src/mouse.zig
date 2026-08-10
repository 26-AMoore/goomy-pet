const std = @import("std");
const rl = @import("raylib");

// I am sorry, this code is not mine

pub fn getGlobalMousePosition() !rl.Vector2 {
    return switch (builtin.os.tag) {
        .linux => getLinuxMousePosition(),
        .macos => getMacOSMousePosition(),
        else => error.UnsupportedPlatform,
    };
}

const builtin = @import("builtin");

fn getLinuxMousePosition() !rl.Vector2 {
    const x11 = @cImport({
        @cInclude("X11/Xlib.h");
    });

    const display = x11.XOpenDisplay(null) orelse
        return error.CannotOpenDisplay;

    defer _ = x11.XCloseDisplay(display);

    const root = x11.XDefaultRootWindow(display);

    var root_return: x11.Window = undefined;
    var child_return: x11.Window = undefined;

    var root_x: c_int = undefined;
    var root_y: c_int = undefined;
    var win_x: c_int = undefined;
    var win_y: c_int = undefined;
    var mask: c_uint = undefined;

    const success = x11.XQueryPointer(
        display,
        root,
        &root_return,
        &child_return,
        &root_x,
        &root_y,
        &win_x,
        &win_y,
        &mask,
    );

    if (success == 0)
        return error.CannotQueryPointer;

    return .{
        .x = @floatFromInt(root_x),
        .y = @floatFromInt(root_y),
    };
}

fn getMacOSMousePosition() !rl.Vector2 {
    const cg = @cImport({
        @cInclude("CoreGraphics/CoreGraphics.h");
    });

    const event = cg.CGEventCreate(null) orelse
        return error.CannotCreateEvent;

    defer cg.CFRelease(event);

    const location = cg.CGEventGetLocation(event);

    return .{
        .x = location.x,
        .y = location.y,
    };
}
