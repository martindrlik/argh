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
        .jump_height = 5 * screen.Vector.tile.v,
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
    self.jump();
    self.horizontalMovement(scene);
    self.verticalMovement(scene);
}

fn jump(self: *Player) void {
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

    if (self.is_grounded) {
        self.input.remaining_coyote_time = self.properties.coyote_time;
    } else {
        self.input.remaining_coyote_time.nanoseconds = @max(
            0,
            self.input.remaining_coyote_time.nanoseconds - physics_step.nanoseconds,
        );
    }
}

fn horizontalMovement(
    self: *Player,
    scene: *Scene,
) void {
    const target_velocity = self.input.horizontal_input * self.properties.move_speed;
    const rate = if (self.input.horizontal_input == 0) self.properties.deceleration else self.properties.acceleration;
    const maximum_change = rate * physics_step_seconds;
    if (self.velocity.h < target_velocity) {
        self.velocity.h = @min(
            self.velocity.h + maximum_change,
            target_velocity,
        );
    } else {
        self.velocity.h = @max(
            self.velocity.h - maximum_change,
            target_velocity,
        );
    }
    self.position.current.h += self.velocity.h * physics_step_seconds;
    self.horizontalCollision(scene);
}

fn verticalMovement(
    self: *Player,
    scene: *Scene,
) void {
    var remaining = physics_step_seconds;
    const max_speed = self.properties.max_fall_speed;

    self.is_grounded = false;
    self.velocity.v = @min(self.velocity.v, max_speed);

    while (remaining > 0) {
        const start_v = self.position.current.v;
        const initial_velocity = self.velocity.v;
        const rising = initial_velocity < 0;

        const gravity: float = if (rising)
            self.properties.gravity(initial_velocity)
        else if (initial_velocity < max_speed)
            self.properties.gravity_fall
        else
            0;

        var duration = remaining;
        var boundary_velocity: ?float = null;

        if (rising) {
            const time_to_peak = -initial_velocity / gravity;
            if (time_to_peak <= duration) {
                duration = time_to_peak;
                boundary_velocity = 0;
            }
        } else if (gravity > 0) {
            const time_to_cap = (max_speed - initial_velocity) / gravity;
            if (time_to_cap <= duration) {
                duration = time_to_cap;
                boundary_velocity = max_speed;
            }
        }

        self.position.current.v = start_v +
            initial_velocity * duration +
            0.5 * gravity * duration * duration;

        if (scene.verticalCollision(self.entity(), start_v)) |collision| {
            const contact_v = switch (collision) {
                .ceiling => |surface| surface,
                .ground => |surface| surface - self.properties.floatSize().v,
            };

            const impact_time = timeToVerticalContact(
                initial_velocity,
                gravity,
                contact_v - start_v,
            );

            const consumed = @max(0, @min(duration, impact_time));
            remaining = @max(0, remaining - consumed);

            self.position.current.v = contact_v;
            self.velocity.v = 0;

            switch (collision) {
                .ground => {
                    self.is_grounded = true;
                    return;
                },
                .ceiling => {
                    // Continue with falling gravity for the remaining time.
                },
            }
        } else {
            self.velocity.v = boundary_velocity orelse
                (initial_velocity + gravity * duration);

            remaining = @max(0, remaining - duration);
        }
    }
}

fn timeToVerticalContact(
    velocity: float,
    gravity: float,
    distance: float,
) float {
    if (distance == 0) return 0;
    if (gravity == 0) return distance / velocity;

    const discriminant = @max(
        0,
        velocity * velocity + 2 * gravity * distance,
    );
    const speed_at_contact = @sqrt(discriminant);

    const denominator = if (velocity < 0)
        velocity - speed_at_contact
    else
        velocity + speed_at_contact;

    return 2 * distance / denominator;
}

fn horizontalCollision(
    self: *Player,
    scene: *Scene,
) void {
    if (self.position.current.h != self.position.previous.h) {
        if (scene.horizontalCollision(self.entity())) |hc| switch (hc) {
            .left => |surface| {
                self.velocity.h = 0;
                self.position.current.h = surface - self.properties.floatSize().h;
            },
            .right => |surface| {
                self.velocity.h = 0;
                self.position.current.h = surface;
            },
        };
    }
}

pub fn draw(
    self: *const Player,
    alpha: float,
) void {
    const rec = self.position.screenRectangle(self.properties.size, alpha);
    rl.drawRectangleRec(rec, .blue);
}
