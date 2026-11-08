const std = @import("std");
const Io = std.Io;

const Engine = @import("Engine.zig");
const Input = @import("Input.zig");
const Player = @import("Player.zig");
const Scene = @import("Scene.zig").Scene;
const Simulation = @import("Simulation.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var input = Input{};
    var engine: Engine = .init();
    var simulation: Simulation = .init(13);

    while (true) {
        if (input.takeLine(io)) |line| {
            if (Input.isJump(line)) {
                if (engine.query(Player)) |player| {
                    std.debug.print("jump requested\n", .{});
                    player.request(.Jump);
                }
            } else if (Input.isLand(line)) {
                input.is_land_requested = true;
            } else if (Input.isQuit(line)) {
                break;
            }
        }

        const elapsed = simulation.elapsed();
        engine.physicsStep(elapsed);
        engine.draw();
    }
}
