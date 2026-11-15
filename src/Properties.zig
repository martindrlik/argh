const std = @import("std");
const Duration = std.Io.Duration;

const core = @import("core.zig");
const Engine = core.Engine;
const Vector = core.Vector;
const float = core.float;
const physics_step = Engine.physics_step;
const screen = core.screen;

const Properties = @This();

acceleration: float,
coyote_time: Duration,
deceleration: float,
gravity_fall: float,
jump_buffer: Duration,
jump_height: float,
jump_time_to_peak: float,
max_fall_speed: float,
move_speed: float,
size: screen.Vector,

pub const player = Properties{
    .acceleration = 600,
    .coyote_time = .fromNanoseconds(physics_step.nanoseconds * 5),
    .deceleration = 1000,
    .gravity_fall = 1200,
    .jump_buffer = .fromNanoseconds(physics_step.nanoseconds * 5),
    .jump_height = 5 * screen.Vector.tile.v,
    .jump_time_to_peak = 0.4,
    .max_fall_speed = 600,
    .move_speed = 250,
    .size = .tile,
};

pub fn gravity(self: *const Properties, vertical_velocity: float) float {
    const gravity_rise: float = 2 * self.jump_height / (self.jump_time_to_peak * self.jump_time_to_peak);
    return if (vertical_velocity < 0) gravity_rise else self.gravity_fall;
}

pub fn jumpVelocity(self: *const Properties) float {
    return -2 * self.jump_height / self.jump_time_to_peak;
}

pub fn floatSize(self: *const Properties) Vector {
    return .fromScreenVector(self.size);
}
