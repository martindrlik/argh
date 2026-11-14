const std = @import("std");
const Io = std.Io;
const Duration = Io.Duration;

const core = @import("core");
const rl = core.rl;
const Engine = core.Engine;
const Player = core.Player;
const float = core.float;
const screen_size = core.screen.Vector.screen;

pub fn main(init: std.process.Init) !void {
    var engine: Engine = try .init(init.io);

    rl.initWindow(screen_size.u, screen_size.v, "argh");
    defer rl.closeWindow();

    rl.setTargetFPS(120);

    while (!rl.windowShouldClose()) {
        const elapsed_seconds: float = rl.frameTime();
        const elapsed: Duration = .fromNanoseconds(@intFromFloat(elapsed_seconds * std.time.ns_per_s));

        if (engine.queryMut(Player)) |player| {
            processPlayerInput(player);
        }

        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(.black);
        engine.physicsStep(elapsed);
        engine.draw();
    }
}

fn processPlayerInput(player: *Player) void {
    player.horizontal_input = 0;
    if (rl.isKeyDown(.a)) player.horizontal_input = -1;
    if (rl.isKeyDown(.d)) player.horizontal_input = 1;

    if (rl.isKeyPressed(.space)) {
        player.request(.Jump);
    }
    if (rl.isKeyReleased(.space)) player.is_jump_released = true;
}
