const std = @import("std");
const Io = std.Io;

const rl = @import("raylib");

const core = @import("core.zig");
const float = core.float;
const Duration = Io.Duration;
const Engine = @import("Engine.zig");
const Player = @import("Player.zig");
const Scene = @import("Scene.zig").Scene;

pub fn main(init: std.process.Init) !void {
    _ = init.io;
    var engine: Engine = .init();

    rl.initWindow(Engine.size.u, Engine.size.v, "argh");
    defer rl.closeWindow();

    rl.setTargetFPS(120);

    while (!rl.windowShouldClose()) {
        const elapsed_seconds: float = rl.getFrameTime();
        const elapsed: Duration = .fromNanoseconds(@intFromFloat(elapsed_seconds * std.time.ns_per_s));

        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(.black);
        engine.physicsStep(elapsed);
        engine.draw();
    }
}
