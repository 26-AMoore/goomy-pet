const rl = @import("raylib");
const main = @import("main.zig");

pub fn loadTextureFromMem(comptime memory: [:0]const u8) !rl.Texture2D {
    return rl.loadTextureFromImage(try rl.loadImageFromMemory(".png", memory));
}

pub fn Vec2(comptime T: type) type {
    return struct {
        x: T,
        y: T,
    };
}

pub const Sprite = struct {
    texture: rl.Texture2D,
    spriteRect: rl.Rectangle,
    frames: i32,
    framesPerSecond: i32,
    frame: i32,
    width: i32,
    height: i32,
    resetFrames: i32,
    fps: i32,

    pub fn update(self: *Sprite, passedFrames: ?i32) void {
        self.frame += passedFrames orelse 1;
        self.spriteRect.x = @as(f32, @floatFromInt(@divFloor(self.frame, self.fps) * @divFloor(self.width, self.frames)));

        if (self.frame == self.resetFrames) {
            self.frame = 0;
        }
    }
    pub fn draw(self: Sprite, position: ?rl.Vector2, tint: ?rl.Color) void {
        rl.drawTextureRec(self.texture, self.spriteRect, position orelse rl.Vector2{ .x = 0, .y = 0 }, tint orelse .white);
    }
    pub fn new(texture: rl.Texture2D, frames: i32, fps: i32, framesPerSecond: ?i32) Sprite {
        // what the fuck
        const spriteRect = rl.Rectangle{ .x = 0.0, .y = 0.0, .height = @floatFromInt(texture.height), .width = @floatFromInt(@divFloor(texture.width, frames)) };
        return Sprite{ .resetFrames = main.target_fps, .width = texture.width, .height = texture.height, .texture = texture, .spriteRect = spriteRect, .frames = frames, .framesPerSecond = framesPerSecond orelse frames, .frame = 0, .fps = fps };
    }
};

pub const Button = struct {
    texture: rl.Texture2D,
    rec: rl.Rectangle,
    pub fn draw(self: Button) void {
        rl.drawTexture(self.texture, @intFromFloat(self.rec.x), @intFromFloat(self.rec.y), .white);
    }
    pub fn new(position: rl.Vector2, texture: rl.Texture2D) Button {
        return Button{ .texture = texture, .rec = rl.Rectangle{ .x = position.x, .y = position.y, .height = @floatFromInt(texture.height), .width = @floatFromInt(texture.width) } };
    }
};
