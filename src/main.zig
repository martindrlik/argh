const std = @import("std");
const Io = std.Io;

const argh = @import("argh");
const rl = @import("raylib");

const entity = @import("gameplay/entity.zig");
const rectanglePad = entity.rectanglePad;
const Entity = entity.Entity;
const Box = entity.Box;
const Text = entity.Text;

const primary_mouse_button = rl.MouseButton.left;

pub fn main(init: std.process.Init) !void {
    _ = init;

    rl.initWindow(800, 700, "hello");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    const box = Box{ .x = 50, .y = 50, .width = 100, .height = 100, .color = .red };
    const text = Text{
        .x = 190,
        .y = 200,
        .font_size = 20,
        .color = .light_gray,
        .text = "Congrats! You created your first window!",
    };
    const entities = [_]Entity{
        Entity{ .box = box },
        Entity{ .text = text },
    };

    while (!rl.windowShouldClose()) {
        const mouse_pos = rl.getMousePosition();
        const primary: MbState = .init(.left);

        for (&entities) |*ent| {
            const has_collision = rl.checkCollisionPointRec(mouse_pos, ent.hitBox());
            if (has_collision and primary.pressed) {
                var en = @constCast(ent);
                en.select(if (ent.isSelected()) false else true);
            }
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);
        for (entities) |ent| {
            ent.draw();
        }
    }
}

const MbState = struct {
    down: bool,
    pressed: bool,
    released: bool,
    up: bool,

    pub fn init(button: rl.MouseButton) MbState {
        return .{
            .down = rl.isMouseButtonDown(button),
            .pressed = rl.isMouseButtonPressed(button),
            .released = rl.isMouseButtonReleased(button),
            .up = rl.isMouseButtonUp(button),
        };
    }
};
