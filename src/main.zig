const std = @import("std");
const Io = std.Io;
const Duration = Io.Duration;

const core = @import("core");
const Engine = core.Engine;
const float = core.float;

pub fn main(init: std.process.Init) !void {
    _ = init.io;
    var engine: Engine = .init();

    core.initWindow(Engine.size.u, Engine.size.v, "argh");
    defer core.closeWindow();

    core.setTargetFPS(120);

    while (!core.windowShouldClose()) {
        const elapsed_seconds: float = core.frameTime();
        const elapsed: Duration = .fromNanoseconds(@intFromFloat(elapsed_seconds * std.time.ns_per_s));

        core.beginDrawing();
        defer core.endDrawing();
        core.clearBackground(.black);
        engine.physicsStep(elapsed);
        engine.draw();
    }
}
