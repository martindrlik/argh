const std = @import("std");
const Io = std.Io;
const Duration = Io.Duration;

const core = @import("core");
const Engine = core.Engine;
const Player = core.Player;
const float = core.float;
const screen_size = core.screen.Vector.screen;

pub fn main(init: std.process.Init) !void {
    var engine: Engine = try .init(init.io);

    core.initWindow(screen_size.u, screen_size.v, "argh");
    defer core.closeWindow();

    core.setTargetFPS(120);

    while (!core.windowShouldClose()) {
        const elapsed_seconds: float = core.frameTime();
        const elapsed: Duration = .fromNanoseconds(@intFromFloat(elapsed_seconds * std.time.ns_per_s));

        if (engine.queryMut(Player)) |player| {
            if (core.isKeyPressed(.space)) {
                player.request(.Jump);
            }
        }

        core.beginDrawing();
        defer core.endDrawing();
        core.clearBackground(.black);
        engine.physicsStep(elapsed);
        engine.draw();
    }
}
