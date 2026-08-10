const rl = @import("raylib");
const std = @import("std");
const utils = @import("utils.zig");
const Sprite = utils.Sprite;

const configFlags = rl.ConfigFlags{ .window_transparent = true, .window_undecorated = true, .window_unfocused = true, .window_topmost = true, .window_resizable = false };

var frame: i32 = 0;

pub const V_windowH = 40;
pub const V_windowW = 30;
const fontSize = 20;
const V_Scale = 5;
const windowH = V_windowH * V_Scale;
const windowW = V_windowW * V_Scale;
pub const target_fps = 30;

const Animation = enum { GOOMY, MOOVY, DYING, BALLED, SNOOZIN };
var current_animation: Animation = Animation.SNOOZIN;

var prevMouseMiddle = false;
var prevMouseRight = false;
var prevMouseLeft = false;

var mouseRight = false;
var mouseLeft = false;
var mouseMiddle = false;

// sprites

pub fn main(init: std.process.Init) anyerror!void {
    const io = init.io;

    var prng: std.Random.IoSource = .{ .io = io };
    const random = prng.interface();

    rl.setConfigFlags(configFlags);

    rl.initWindow(windowW, windowH, "I love you <3");
    rl.setConfigFlags(configFlags);
    rl.setWindowIcon(try rl.loadImageFromMemory(".png", @embedFile("sprites/goomy.png")));
    defer rl.closeWindow();

    rl.setExitKey(rl.KeyboardKey.null);

    const monitor = rl.getCurrentMonitor();
    const screenHeight = rl.getMonitorHeight(monitor);
    const screenWidth = rl.getMonitorWidth(monitor);

    _ = .{ screenWidth, screenHeight, monitor };

    var targetPos: rl.Vector2 = .{ .x = 0, .y = 0 };
    var movementVec: rl.Vector2 = .{ .x = 0, .y = 0 };
    var windowPos: rl.Vector2 = .{ .x = 100, .y = 100 };
    var renderButtons = false;

    // GOOMY
    var goomy = Sprite.new(try utils.loadTextureFromMem(@embedFile("sprites/goomy-sheet.png")), 2, 8, null);
    var moovemy = Sprite.new(try utils.loadTextureFromMem(@embedFile("sprites/moovemy-sheet.png")), 2, 8, null);
    var dying = Sprite.new(try utils.loadTextureFromMem(@embedFile("sprites/goonemy-sheet.png")), 19, 3, null);
    var balled = Sprite.new(try utils.loadTextureFromMem(@embedFile("sprites/ball-sheet.png")), 1, 1, null);
    var snoozin = Sprite.new(try utils.loadTextureFromMem(@embedFile("sprites/sleepy-sheet.png")), 2, 50, null);
    snoozin.resetFrames = 120;

    // BUTTONS
    const sleepButton = utils.Button.new(rl.Vector2{ .x = 0, .y = 0 }, try utils.loadTextureFromMem(@embedFile("sprites/sleep.png")));

    rl.setTargetFPS(target_fps);

    const renderTexture: rl.RenderTexture2D = try rl.loadRenderTexture(V_windowW, V_windowH);
    var renderTextureSrc: rl.Rectangle = rl.Rectangle{
        .x = 0.0,
        .y = 0.0,
        .width = V_windowW,
        .height = -V_windowH,
    };
    const renderTextureDest: rl.Rectangle = rl.Rectangle{
        .x = 0.0,
        .y = 0.0,
        .width = windowW,
        .height = windowH,
    };
    const renderTextureOrig: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 };
    defer rl.unloadRenderTexture(renderTexture);

    while (!rl.windowShouldClose()) {
        mouseLeft = rl.isMouseButtonPressed(rl.MouseButton.left);
        mouseRight = rl.isMouseButtonPressed(rl.MouseButton.right);
        mouseMiddle = rl.isMouseButtonPressed(rl.MouseButton.middle);

        if (!renderButtons) {
            switch (current_animation) {
                Animation.BALLED => {
                    if (mouseRight and !prevMouseRight) {
                        current_animation = Animation.GOOMY;
                        windowPos = rl.getWindowPosition();
                        targetPos = rl.getWindowPosition();
                    }
                    if (rl.isMouseButtonDown(rl.MouseButton.left)) {
                        const delta = rl.getMouseDelta();
                        windowPos = windowPos.add(delta);

                        rl.setWindowPosition(@trunc(windowPos.x), @trunc(windowPos.y));
                    }
                },
                Animation.SNOOZIN => {
                    if (random.intRangeAtMost(i32, 0, 2400) == 1) {
                        current_animation = Animation.GOOMY;
                    }
                    if (mouseLeft and !prevMouseLeft) {
                        current_animation = Animation.GOOMY;
                        windowPos = rl.getWindowPosition();
                        targetPos = rl.getWindowPosition();
                    }
                    if (mouseRight and !prevMouseRight) {
                        current_animation = Animation.BALLED;
                    }
                },
                Animation.GOOMY => {
                    if (random.intRangeAtMost(i32, 0, 120) == 1) {
                        targetPos = .{ .x = @floatFromInt(random.intRangeAtMost(i32, 0, screenWidth - windowW)), .y = @floatFromInt(random.intRangeAtMost(i32, 0, screenHeight - windowH)) };
                        current_animation = Animation.MOOVY;
                    }
                    if (mouseRight and !prevMouseRight) {
                        current_animation = Animation.BALLED;
                    }
                    if (rl.isMouseButtonDown(rl.MouseButton.left)) {
                        const delta = rl.getMouseDelta();
                        windowPos = windowPos.add(delta);
                        rl.setWindowPosition(@trunc(windowPos.x), @trunc(windowPos.y));
                    }
                },
                else => {
                    if (random.intRangeAtMost(i32, 0, 1200) == 1) {
                        current_animation = Animation.SNOOZIN;
                    }
                    if (rl.isMouseButtonDown(rl.MouseButton.left)) {
                        const delta = rl.getMouseDelta();
                        windowPos = windowPos.add(delta);
                    }
                    if (mouseRight and !prevMouseRight) {
                        current_animation = Animation.BALLED;
                    }
                    if (current_animation == Animation.MOOVY) {
                        if (windowPos.subtract(targetPos).length() <= 5) {
                            current_animation = Animation.GOOMY;
                        } else {
                            movementVec = targetPos.subtract(windowPos).normalize().clampValue(0, 10).scale(10);
                            windowPos = windowPos.add(movementVec);
                        }
                    }
                    rl.setWindowPosition(@trunc(windowPos.x), @trunc(windowPos.y));
                },
            }
        }

        if (mouseMiddle and !prevMouseMiddle) {
            renderButtons = !renderButtons;
        }

        rl.beginTextureMode(renderTexture);
        {
            rl.clearBackground(.{ .a = 0, .r = 0, .b = 0, .g = 0 });

            switch (current_animation) {
                Animation.GOOMY => {
                    goomy.update(null);
                    goomy.draw(.{ .x = 1, .y = 1 }, null);
                },
                Animation.MOOVY => {
                    moovemy.update(null);
                    moovemy.draw(.{ .x = 1, .y = 1 }, null);
                },
                Animation.DYING => {
                    dying.update(null);
                    dying.draw(.{ .x = 1, .y = 1 }, null);
                },
                Animation.BALLED => {
                    balled.update(null);
                    balled.draw(.{ .x = 0, .y = 0 }, null);
                },
                Animation.SNOOZIN => {
                    snoozin.update(null);
                    snoozin.draw(.{ .x = 1, .y = 1 }, null);
                },
            }
            if (renderButtons) {
                sleepButton.draw();
            }

            frame = @mod((frame + 1), 60);
        }
        rl.endTextureMode();

        // draw to real window
        rl.beginDrawing();
        rl.clearBackground(.blank);
        if (movementVec.x < 0 and renderTextureSrc.width < 0) {
            renderTextureSrc.width = renderTextureSrc.width * -1;
        } else if (movementVec.x > 0 and renderTextureSrc.width > 0) {
            renderTextureSrc.width = renderTextureSrc.width * -1;
        }
        rl.drawTexturePro(renderTexture.texture, renderTextureSrc, renderTextureDest, renderTextureOrig, 0, .white);
        // try drawFps();
        rl.endDrawing();
        prevMouseMiddle = mouseMiddle;
        prevMouseRight = mouseRight;
        prevMouseLeft = mouseLeft;
    }
}

fn drawFps() !void {
    var fps_buf: [10]u8 = undefined; //Okay because we know buffer size and it is constant
    const fps: [:0]u8 = try std.fmt.bufPrintSentinel(&fps_buf, "{d}:{d}", .{ rl.getFPS(), frame }, 0);
    const fpsSize = rl.measureText(fps, fontSize);

    rl.drawRectangle(0, 0, fpsSize + 4, fontSize, .black);
    rl.drawText(fps, 1, 0, fontSize, .green);
}

fn printCentered(text: [:0]const u8, x: i32, y: i32, fontsize: ?i32, color: ?rl.Color) !void {
    const size = rl.measureText(text, fontsize orelse 20);
    rl.drawText(text, x - @divFloor(size, 2), y, fontsize orelse 20, color orelse .black);
}
