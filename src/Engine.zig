const std = @import("std");
const Duration = std.Io.Duration;

const core = @import("core.zig");
const ScreenVector = core.ScreenVector;
const scene = @import("scene.zig");
const Scene = scene.Scene;

const Engine = @This();
const max_physics_steps_per_frame: u32 = 5;
pub const physics_step: std.Io.Duration = .fromNanoseconds((std.time.ns_per_s + 30) / 60);
pub const physics_step_seconds = @as(f64, @floatFromInt(physics_step.nanoseconds)) / std.time.ns_per_s;
pub const size: ScreenVector = .new(1024, 768);

accumulator: Duration = .zero,
scenes: [1]Scene,

pub fn init() Engine {
    return .{
        .scenes = @splat(Scene{ .game = .init() }),
    };
}

pub fn queryActive(self: *Engine, comptime T: type) ?*T {
    for (&self.scenes) |scn| {
        switch (&scn) {
            .game => |*game| {
                return game.queryMutEntity(T);
            },
        }
    }
    return null;
}

pub fn physicsStep(self: *Engine, elapsed: Duration) void {
    self.accumulator.nanoseconds += elapsed.nanoseconds;

    var remaining_physics_steps = max_physics_steps_per_frame;
    while (self.accumulator.nanoseconds >= physics_step.nanoseconds and remaining_physics_steps > 0) {
        for (&self.scenes) |*scn| scn.physicsStep();
        self.accumulator.nanoseconds -= physics_step.nanoseconds;
        remaining_physics_steps -= 1;
    }
    self.accumulator.nanoseconds = @mod(self.accumulator.nanoseconds, physics_step.nanoseconds);
}

pub fn draw(self: *const Engine) void {
    const alpha = self.computeAlpha();
    for (self.scenes) |scn| scn.draw(alpha);
}

fn computeAlpha(self: *const Engine) f64 {
    const accumulator_ns: f64 = @floatFromInt(self.accumulator.nanoseconds);
    const step_ns: f64 = @floatFromInt(physics_step.nanoseconds);
    return accumulator_ns / step_ns;
}
