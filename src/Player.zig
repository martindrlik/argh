const debug = @import("debug.zig");
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
    if (input.consumeJumpRequest()) {
        debug.printPlayerJumpRequestConsumed();
        if (self.is_grounded) {
            debug.printPlayerJumped();
            self.is_airborne = true;
            self.is_grounded = false;
        }
    }
    if (input.consumeLandRequest()) {
        if (self.is_airborne) {
            debug.printPlayerLanded();
            self.is_airborne = false;
            self.is_grounded = true;
        }
    }
}

pub fn draw(self: *const Player, alpha: f64) void {
    debug.printPlayer(self, alpha);
}
