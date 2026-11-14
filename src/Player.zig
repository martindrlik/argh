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
pub const jump_buffer: Duration = .fromNanoseconds(physics_step.nanoseconds * 5);
pub const coyote_time: Duration = .fromNanoseconds(physics_step.nanoseconds * 5);
pub const size: screen.Vector = .tile;

is_grounded: bool,
is_jump_released: bool = true,
vertical_velocity: float = 400,
position: Position,
remaining_coyote_time: Duration,
remaining_jump_buffer: Duration,
velocity: Vector,

pub fn new(position: Position, is_grounded: bool) Player {
    return .{
        .is_grounded = is_grounded,
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
        .Jump => self.remaining_jump_buffer = jump_buffer,
    }
}

pub fn entity(self: *Player) *Entity {
    return @fieldParentPtr("player", self);
}

pub fn physicsStep(self: *Player, scene: *Scene) void {
    self.position.previous = self.position.current;
    self.processJump();
    self.processGravity(scene);
    self.processCoyoteTime();
    self.processCollision(scene);
}

fn processJump(self: *Player) void {
    const can_jump = self.is_grounded or self.remaining_coyote_time.nanoseconds > 0;
    if (self.remaining_jump_buffer.nanoseconds > 0 and can_jump) {
        self.velocity.v = -self.vertical_velocity;
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

fn processGravity(self: *Player, scene: *Scene) void {
    if (!self.is_grounded) {
        self.velocity.v += scene.gravity() * physics_step_seconds;
        self.position.current.v += self.velocity.v * physics_step_seconds;
    }
}

fn processCoyoteTime(self: *Player) void {
    if (self.is_grounded) {
        self.remaining_coyote_time = coyote_time;
    } else {
        self.remaining_coyote_time.nanoseconds = @max(
            0,
            self.remaining_coyote_time.nanoseconds - physics_step.nanoseconds,
        );
    }
}

fn processCollision(self: *Player, scene: *Scene) void {
    if (self.position.current.u != self.position.previous.u) {
        // TODO check horizontal collisions
    }
    if (self.position.current.v != self.position.previous.v) {
        if (scene.checkVCollision(self.entity())) |vc| switch (vc) {
            .ceiling => {},
            .ground => |v| {
                self.is_grounded = true;
                self.velocity.v = 0;
                self.position.current.v = v - size.v;
            },
        };
    }
}

pub fn draw(self: *const Player, alpha: float) void {
    const rec = self.position.screenRectangle(size, alpha);
    rl.drawRectangleRec(rec, .blue);
}
