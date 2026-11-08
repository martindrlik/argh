const std = @import("std");
const Duration = std.Io.Duration;

const core = @import("core.zig");
const ScreenVector = core.ScreenVector;
const Player = @import("Player.zig");
const Scene = @import("Scene.zig").Scene;

const Engine = @This();
const max_physics_steps_per_frame: u32 = 5;
pub const physics_step: std.Io.Duration = .fromNanoseconds((std.time.ns_per_s + 30) / 60);
pub const physics_step_seconds = @as(f64, @floatFromInt(physics_step.nanoseconds)) / std.time.ns_per_s;
pub const size: ScreenVector = .new(1024, 768);

accumulator: Duration = .zero,
scene: Scene,

pub fn init() Engine {
    return .{
        .scene = .{ .game = .init() },
    };
}

pub fn query(self: *Engine, comptime T: type) ?*T {
    for (&self.scene.game.entities) |*entity| {
        switch (entity.*) {
            inline else => |*payload| {
                if (@TypeOf(payload) == *T) {
                    return payload;
                }
            },
        }
    }
    return null;
}

pub fn physicsStep(self: *Engine, elapsed: Duration) void {
    self.accumulator.nanoseconds += elapsed.nanoseconds;

    var remaining_physics_steps = max_physics_steps_per_frame;
    while (self.accumulator.nanoseconds >= physics_step.nanoseconds and remaining_physics_steps > 0) {
        self.scene.physicsStep();
        self.accumulator.nanoseconds -= physics_step.nanoseconds;
        remaining_physics_steps -= 1;
    }
    self.accumulator.nanoseconds = @mod(self.accumulator.nanoseconds, physics_step.nanoseconds);
}

pub fn draw(self: *const Engine) void {
    const alpha = self.computeAlpha();
    self.scene.draw(alpha);
}

fn computeAlpha(self: *const Engine) f64 {
    const accumulator_ns: f64 = @floatFromInt(self.accumulator.nanoseconds);
    const step_ns: f64 = @floatFromInt(physics_step.nanoseconds);
    return accumulator_ns / step_ns;
}
