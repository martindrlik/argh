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

const Properties = struct {
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

    pub const default = Properties{
        .acceleration = 600,
        .coyote_time = .fromNanoseconds(physics_step.nanoseconds * 5),
        .deceleration = 1000,
        .gravity_fall = 1200,
        .jump_buffer = .fromNanoseconds(physics_step.nanoseconds * 5),
        .jump_height = 3 * screen.Vector.tile.u,
        .jump_time_to_peak = 0.4,
        .max_fall_speed = 600,
        .move_speed = 200,
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
};

const Input = struct {
    horizontal_input: float,
    is_jump_held: bool,
    is_jump_released: bool,
    remaining_coyote_time: Duration,
    remaining_jump_buffer: Duration,

    pub const none = Input{
        .horizontal_input = 0,
        .is_jump_held = false,
        .is_jump_released = false,
        .remaining_coyote_time = .zero,
        .remaining_jump_buffer = .zero,
    };
};

input: Input,
is_grounded: bool,
position: Position,
properties: Properties,
velocity: Vector,

pub fn new(position: Position, is_grounded: bool) Player {
    return .{
        .input = .none,
        .is_grounded = is_grounded,
        .position = position,
        .properties = .default,
        .velocity = .zero,
    };
}

pub fn requestJump(self: *Player) void {
    self.input.remaining_jump_buffer = self.properties.jump_buffer;
}

pub fn entity(self: *Player) *Entity {
    return @fieldParentPtr("player", self);
}

pub fn physicsStep(self: *Player, scene: *Scene) void {
    self.position.previous = self.position.current;

    self.processJump();
    self.processCoyoteTime();

    self.processHorizontalMovement();
    self.processHCollision(scene);

    self.processGravity();
    self.processVCollision(scene);
}

fn processJump(self: *Player) void {
    const can_jump =
        self.is_grounded or
        self.input.remaining_coyote_time.nanoseconds > 0;
    const started_jump =
        self.input.remaining_jump_buffer.nanoseconds > 0 and
        can_jump;

    if (started_jump) {
        self.velocity.v = self.properties.jumpVelocity();
        self.is_grounded = false;
        self.input.remaining_jump_buffer = .zero;
        self.input.remaining_coyote_time = .zero;
    }

    const should_cut_jump =
        self.input.is_jump_released or
        (started_jump and !self.input.is_jump_held);

    if (should_cut_jump and self.velocity.v < 0) {
        self.velocity.v *= 0.5;
    }

    self.input.is_jump_released = false;

    self.input.remaining_jump_buffer = .{
        .nanoseconds = @max(
            0,
            self.input.remaining_jump_buffer.nanoseconds - physics_step.nanoseconds,
        ),
    };
}

fn processHorizontalMovement(self: *Player) void {
    const target_velocity = self.input.horizontal_input * self.properties.move_speed;
    const rate = if (self.input.horizontal_input == 0) self.properties.deceleration else self.properties.acceleration;
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
    self.velocity.v += self.properties.gravity(self.velocity.v) * physics_step_seconds;
    self.velocity.v = @min(self.velocity.v, self.properties.max_fall_speed);
    self.position.current.v += self.velocity.v * physics_step_seconds;
}

fn processCoyoteTime(self: *Player) void {
    if (self.is_grounded) {
        self.input.remaining_coyote_time = self.properties.coyote_time;
    } else {
        self.input.remaining_coyote_time.nanoseconds = @max(
            0,
            self.input.remaining_coyote_time.nanoseconds - physics_step.nanoseconds,
        );
    }
}

fn processHCollision(self: *Player, scene: *Scene) void {
    if (self.position.current.u != self.position.previous.u) {
        if (scene.checkHCollision(self.entity())) |hc| switch (hc) {
            .left_wall => |u| {
                self.velocity.u = 0;
                self.position.current.u = u - self.properties.floatSize().u;
            },
            .right_wall => |u| {
                self.velocity.u = 0;
                self.position.current.u = u;
            },
        };
    }
}

fn processVCollision(self: *Player, scene: *Scene) void {
    self.is_grounded = false;

    if (self.position.current.v != self.position.previous.v) {
        if (scene.checkVCollision(self.entity())) |vc| switch (vc) {
            .ceiling => |v| {
                self.velocity.v = 0;
                self.position.current.v = v;
            },
            .ground => |v| {
                self.is_grounded = true;
                self.velocity.v = 0;
                self.position.current.v = v - self.properties.floatSize().v;
            },
        };
    }
}

pub fn draw(self: *const Player, alpha: float) void {
    const rec = self.position.screenRectangle(self.properties.size, alpha);
    rl.drawRectangleRec(rec, .blue);
}
