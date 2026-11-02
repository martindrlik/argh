const Engine = @This();
const std = @import("std");
const Scene = @import("Scene.zig").Scene;
const Duration = std.Io.Duration;
const debug = @import("debug.zig");

const max_physics_steps_per_frame: u32 = 5;
pub const physics_step: std.Io.Duration = .fromNanoseconds((std.time.ns_per_s + 30) / 60);
pub const physics_step_seconds = @as(f64, @floatFromInt(physics_step.nanoseconds)) / std.time.ns_per_s;

accumulator: Duration = .zero,
scene: Scene,

pub fn init() Engine {
    return .{
        .scene = .{ .game = .init() },
    };
}

pub fn physicsStep(self: *Engine, elapsed: Duration) void {
    self.accumulator.nanoseconds += elapsed.nanoseconds;

    debug.printAccumulator(self.accumulator);

    if (self.accumulator.nanoseconds < physics_step.nanoseconds) {
        debug.printPhysicsStepOmitted();
    }
    var remaining_physics_steps = max_physics_steps_per_frame;
    while (self.accumulator.nanoseconds >= physics_step.nanoseconds and remaining_physics_steps > 0) {
        self.scene.physicsStep();
        self.accumulator.nanoseconds -= physics_step.nanoseconds;
        remaining_physics_steps -= 1;
    }
    self.accumulator.nanoseconds = @mod(self.accumulator.nanoseconds, physics_step.nanoseconds);
}

test physicsStep {
    var engine: Engine = .init();
    engine.accumulator = .fromNanoseconds(2 * physics_step.nanoseconds);
    engine.physicsStep();
    try std.testing.expect(engine.accumulator.nanoseconds == 0.0);
}

pub fn draw(self: *const Engine) void {
    const alpha = self.computeAlpha();
    debug.printAlpha(alpha);
    self.scene.draw(alpha);
}

fn computeAlpha(self: *const Engine) f64 {
    const accumulator_ns: f64 = @floatFromInt(self.accumulator.nanoseconds);
    const step_ns: f64 = @floatFromInt(physics_step.nanoseconds);
    return accumulator_ns / step_ns;
}
