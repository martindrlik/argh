const std = @import("std");
const Duration = std.Io.Duration;

const rl = @import("raylib");

const core = @import("core.zig");
const Position = core.Position;
const Scene = core.Scene;
const Vector = core.Vector;
const float = core.float;
const Engine = core.Engine;
const physics_step = Engine.physics_step;
const physics_step_seconds = Engine.physics_step_seconds;
const Entity = core.Entity;
const screen = core.screen;

const Player = @This();

pub const bounds = struct {
    acceleration: float = 600,
    coyote_time: Duration = .fromNanoseconds(physics_step.nanoseconds * 5),
    deceleration: float = 1000,
    fall_speed: float = 600,
    jump_buffer: Duration = .fromNanoseconds(physics_step.nanoseconds * 5),
    move_speed: float = 200,
    size: screen.Vector = .tile,
}{};

gravity_fall: float,
gravity_rise: float,
horizontal_input: float = 0,
is_grounded: bool,
is_jump_released: bool = false,
jump_vertical_velocity: float,
position: Position,
remaining_coyote_time: Duration,
remaining_jump_buffer: Duration,
velocity: Vector,

pub fn new(position: Position, is_grounded: bool) Player {
    return .{
        .gravity_fall = 1200,
        .gravity_rise = 500,
        .is_grounded = is_grounded,
        .jump_vertical_velocity = -400,
        .position = position,
        .remaining_coyote_time = .zero,
        .remaining_jump_buffer = .zero,
        .velocity = .zero,
    };
}

pub const Action = enum {
    Jump,
};

pub fn request(self: *Player, action: Action) void {
    switch (action) {
        .Jump => self.remaining_jump_buffer = bounds.jump_buffer,
    }
}

pub fn entity(self: *Player) *Entity {
    return @fieldParentPtr("player", self);
}

pub fn physicsStep(self: *Player, scene: *Scene) void {
    self.position.previous = self.position.current;
    self.processJump();
    self.processHorizontalMovement();
    self.processGravity();
    self.processCoyoteTime();
    self.processCollision(scene);
}

fn processJump(self: *Player) void {
    const can_jump = self.is_grounded or self.remaining_coyote_time.nanoseconds > 0;
    if (self.remaining_jump_buffer.nanoseconds > 0 and can_jump) {
        self.velocity.v = self.jump_vertical_velocity;
        self.is_grounded = false;
        self.remaining_jump_buffer = .zero;
        self.remaining_coyote_time = .zero;
    }
    if (self.is_jump_released) {
        if (self.velocity.v < 0) {
            self.velocity.v *= 0.5;
        }
        self.is_jump_released = false;
    }
    self.remaining_jump_buffer = .{
        .nanoseconds = @max(
            0,
            self.remaining_jump_buffer.nanoseconds - physics_step.nanoseconds,
        ),
    };
}

fn processHorizontalMovement(self: *Player) void {
    const target_velocity = self.horizontal_input * bounds.move_speed;
    const rate = if (self.horizontal_input == 0) bounds.deceleration else bounds.acceleration;
    const maximum_change = rate * physics_step_seconds;
    if (self.velocity.u < target_velocity) {
        self.velocity.u = @min(
            self.velocity.u + maximum_change,
            target_velocity,
        );
    } else {
        self.velocity.u = @max(
            self.velocity.u - maximum_change,
            target_velocity,
        );
    }
    self.position.current.u += self.velocity.u * physics_step_seconds;
}

fn processGravity(self: *Player) void {
    self.velocity.v += self.gravity() * physics_step_seconds;
    self.velocity.v = @min(self.velocity.v, bounds.fall_speed);
    self.position.current.v += self.velocity.v * physics_step_seconds;
}

fn processCoyoteTime(self: *Player) void {
    if (self.is_grounded) {
        self.remaining_coyote_time = bounds.coyote_time;
    } else {
        self.remaining_coyote_time.nanoseconds = @max(
            0,
            self.remaining_coyote_time.nanoseconds - physics_step.nanoseconds,
        );
    }
}

fn processCollision(self: *Player, scene: *Scene) void {
    self.is_grounded = false;

    if (self.position.current.u != self.position.previous.u) {
        // TODO check horizontal collisions
    }
    if (self.position.current.v != self.position.previous.v) {
        if (scene.checkVCollision(self.entity())) |vc| switch (vc) {
            .ceiling => |v| {
                self.velocity.v = 0;
                self.position.current.v = v;
            },
            .ground => |v| {
                self.is_grounded = true;
                self.velocity.v = 0;
                self.position.current.v = v - bounds.size.v;
            },
        };
    }
}

fn gravity(self: *const Player) float {
    return if (self.velocity.v < 0) self.gravity_rise else self.gravity_fall;
}

pub fn draw(self: *const Player, alpha: float) void {
    const rec = self.position.screenRectangle(bounds.size, alpha);
    rl.drawRectangleRec(rec, .blue);
}
