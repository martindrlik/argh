const std = @import("std");
const Io = std.Io;
const Duration = std.Io.Duration;

const core = @import("core.zig");
const ScreenVector = core.ScreenVector;
const World = @import("World.zig");
const Layer = World.Layer;

const Engine = @This();
const max_physics_steps_per_frame: u32 = 5;
pub const physics_step: std.Io.Duration = .fromNanoseconds((std.time.ns_per_s + 30) / 60);
pub const physics_step_seconds = @as(f64, @floatFromInt(physics_step.nanoseconds)) / std.time.ns_per_s;

accumulator: Duration = .zero,
worlds: [1]World,

pub fn init(io: Io) !Engine {
    return .{
        .worlds = @splat(World{
            .layers = @splat(Layer{
                .game = try .load(io, "assets/maps/level_1.txt"),
            }),
        }),
    };
}

pub fn queryMut(self: *Engine, comptime T: type) ?*T {
    for (&self.worlds) |*world| {
        if (world.queryMut(T)) |match| {
            return match;
        }
    }
    return null;
}

pub fn physicsStep(self: *Engine, elapsed: Duration) void {
    self.accumulator.nanoseconds += elapsed.nanoseconds;

    var remaining_physics_steps = max_physics_steps_per_frame;
    while (self.accumulator.nanoseconds >= physics_step.nanoseconds and remaining_physics_steps > 0) {
        for (&self.worlds) |*world| world.physicsStep();
        self.accumulator.nanoseconds -= physics_step.nanoseconds;
        remaining_physics_steps -= 1;
    }
    self.accumulator.nanoseconds = @mod(self.accumulator.nanoseconds, physics_step.nanoseconds);
}

pub fn draw(self: *const Engine) void {
    const accumulator_ns: f64 = @floatFromInt(self.accumulator.nanoseconds);
    const step_ns: f64 = @floatFromInt(physics_step.nanoseconds);
    const alpha = accumulator_ns / step_ns;
    for (self.worlds) |world| world.draw(alpha);
}
