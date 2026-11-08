const std = @import("std");
const Duration = std.Io.Duration;

const rl = @import("raylib");

const core = @import("core.zig");
const Position = core.Position;
const Vector = core.Vector;
const ScreenVector = core.ScreenVector;
const int = core.int;
const float = core.float;
const Engine = @import("Engine.zig");
const physics_step = Engine.physics_step;

const Player = @This();
pub const jump_buffer: Duration = .fromNanoseconds(physics_step.nanoseconds * 5);
pub const coyote_time: Duration = .fromNanoseconds(physics_step.nanoseconds * 5);
pub const size: ScreenVector = .small;

health: int,
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
    .remaining_coyote_time = .zero,
    .remaining_jump_buffer = .zero,
    .velocity = .zero,
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
    const rec = self.position.screenRectangle(size, alpha);
    rl.drawRectangleRec(rec, .blue);
}
