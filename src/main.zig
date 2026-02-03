const std = @import("std");
const argh = @import("argh");

pub fn main() !void {
    argh.initWindow(
        argh.V.screen.x,
        argh.V.screen.y,
        "argh",
    );
    defer argh.closeWindow();

    argh.setTargetFps(60);

    var player = argh.O.object(.still(.zero), .small, argh.blue);

    var player_anim = [_]argh.S{
        .slow(.in(.small, argh.V.screen.x, 0)),
        .fast(.in(.small, argh.V.screen.x, argh.V.screen.y)),
        .sonic(.in(.small, 0, argh.V.screen.y)),
        .slow(.zero),
    };

    var enemy = argh.O.object(
        .slow(.in(.small, argh.V.screen.x, argh.V.screen.y)),
        .small,
        argh.red,
    );

    var enemy_anim = [_]argh.S{
        .fast(.in(.small, 0, argh.V.screen.y)),
        .slow(.zero),
        .slow(.in(.small, argh.V.screen.x, 0)),
        .sonic(.in(.small, argh.V.screen.x, argh.V.screen.y)),
    };

    player.setAnimation(&player_anim);
    enemy.setAnimation(&enemy_anim);

    while (!argh.windowShouldClose()) {
        player.update();
        enemy.update();

        argh.beginDrawing();
        argh.clearBackground(argh.black);
        player.draw();
        enemy.draw();
        argh.endDrawing();
    }
}
