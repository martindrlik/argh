const std = @import("std");
const Io = std.Io;
const debug = @import("debug.zig");

const Engine = @import("Engine.zig");
const Scene = @import("Scene.zig").Scene;
const Input = @import("Input.zig");
const Simulation = @import("Simulation.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var input = Input{};
    var engine: Engine = .init();
    var simulation: Simulation = .init(13);

    while (true) {
        if (input.takeLine(io)) |line| {
            if (Input.isJump(line)) {
                input.is_jump_requested = true;
            } else if (Input.isQuit(line)) {
                break;
            }
        }

        const elapsed = simulation.elapsed();
        debug.printElapsed(elapsed);
        engine.physicsStep(&input, elapsed);
        engine.draw();
    }
}
