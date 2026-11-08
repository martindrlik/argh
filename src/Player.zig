const std = @import("std");
const Duration = std.Io.Duration;

const core = @import("core.zig");
const Position = core.Position;
const Vector = core.Vector;
const unsigned = core.unsigned;
const float = core.float;
const Engine = @import("Engine.zig");
const physics_step = Engine.physics_step;

const Player = @This();
pub const jump_buffer: Duration = .{ .nanoseconds = physics_step.nanoseconds * 5 };
pub const coyote_time: Duration = .{ .nanoseconds = physics_step.nanoseconds * 5 };

health: unsigned,
is_airborne: bool,
is_grounded: bool,
position: Position,
remaining_coyote_time: Duration,
remaining_jump_buffer: Duration,
velocity: Vector,

pub const default: Player = .{
    .health = 100,
    .is_airborne = false,
    .is_grounded = true,
    .position = .zero,
    .remaining_coyote_time = coyote_time,
    .remaining_jump_buffer = jump_buffer,
    .velocity = .new(15, 10),
};

pub const Action = enum {
    Jump,
};

pub fn request(self: *Player, action: Action) void {
    switch (action) {
        .Jump => self.remaining_jump_buffer = jump_buffer,
    }
}

pub fn physicsStep(self: *Player) void {
    self.resolveJump();
    if (self.is_grounded) {
        self.remaining_coyote_time = coyote_time;
    } else {
        self.remaining_coyote_time.nanoseconds = @max(
            0,
            self.remaining_coyote_time.nanoseconds - physics_step.nanoseconds,
        );
    }
}

fn resolveJump(self: *Player) void {
    if (self.remaining_jump_buffer.nanoseconds > 0 and self.remaining_coyote_time.nanoseconds > 0) {
        self.is_airborne = true;
        self.is_grounded = false;
        self.remaining_jump_buffer = .zero;
        self.remaining_coyote_time = .zero;
    }
    self.remaining_jump_buffer = .{
        .nanoseconds = @max(
            0,
            self.remaining_jump_buffer.nanoseconds - physics_step.nanoseconds,
        ),
    };
}

pub fn draw(self: *const Player, alpha: float) void {
    _ = self;
    _ = alpha;
}
