const std = @import("std");
const argh = @import("argh");
const rainbow = @import("scene/rainbow.zig");

pub fn main() !void {
    argh.initWindow(
        argh.V.screen.x,
        argh.V.screen.y,
        "argh",
    );
    defer argh.closeWindow();

    argh.setTargetFps(60);

    const fg = foreground(){};
    var snake = rainbow.snake().create();

    while (!argh.windowShouldClose()) {
        snake.update();

        argh.beginDrawing();
        argh.clearBackground(argh.black);
        defer argh.endDrawing();

        fg.draw();
        snake.draw();
    }
}

fn foreground() type {
    const argh_text = argh.text.static("argh!", 100, 100, .large){};
    const lets_go_have_some_adventures_together_text = argh.text.static("Let's go have some adventures together!", 100, 150, .medium){};
    return struct {
        pub fn draw(_: @This()) void {
            argh_text.draw();
            lets_go_have_some_adventures_together_text.draw();
        }
    };
}
