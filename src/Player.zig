const std = @import("std");
const Duration = std.Io.Duration;

const Engine = @import("Engine.zig");
const physics_step = Engine.physics_step;
const Input = @import("Input.zig");
const Position = @import("Position.zig");
const Vector = Position.Vector;

const Player = @This();
health: u32,
is_airborne: bool,
is_grounded: bool,
position: Position,
velocity: Vector,

pub fn init() Player {
    return .{
        .health = 100,
        .is_airborne = false,
        .is_grounded = true,
        .position = .zero(),
        .velocity = Vector{ .u = 15.0, .v = 10.0 },
    };
}

pub fn physicsStep(self: *Player, input: *Input) void {
    if (input.remaining_jump_buffer.nanoseconds > 0 and self.is_grounded) {
        self.is_airborne = true;
        self.is_grounded = false;
        input.remaining_jump_buffer = .zero;
    }
    input.remaining_jump_buffer = .{
        .nanoseconds = @max(
            0,
            input.remaining_jump_buffer.nanoseconds - physics_step.nanoseconds,
        ),
    };
    if (input.consumeLandRequest()) {
        if (self.is_airborne) {
            self.is_airborne = false;
            self.is_grounded = true;
        }
    }
}

test "physicsStep remaining jump buffer" {
    var input = Input{};
    var player = Player.init();

    player.is_airborne = true;
    player.is_grounded = false;

    try std.testing.expect(input.remaining_jump_buffer.nanoseconds == Duration.zero.nanoseconds);
    input.requestJump();
    try std.testing.expect(input.remaining_jump_buffer.nanoseconds == 5 * physics_step.nanoseconds);

    player.physicsStep(&input);
    try std.testing.expect(input.remaining_jump_buffer.nanoseconds == 4 * physics_step.nanoseconds);
    try std.testing.expect(player.is_airborne);
    try std.testing.expect(!player.is_grounded);

    player.is_airborne = false;
    player.is_grounded = true;
    player.physicsStep(&input);
    try std.testing.expect(input.remaining_jump_buffer.nanoseconds == Duration.zero.nanoseconds);
    try std.testing.expect(player.is_airborne);
    try std.testing.expect(!player.is_grounded);
}

pub fn draw(self: *const Player, alpha: f64) void {
    _ = self;
    _ = alpha;
}
