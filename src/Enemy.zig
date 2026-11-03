const Engine = @import("Engine.zig");
const physics_step_seconds = Engine.physics_step_seconds;
const Position = @import("Position.zig");
const Vector = Position.Vector;
const debug = @import("debug.zig");

const Enemy = @This();

health: u32,
name: []const u8,
position: Position,
velocity: Vector,

pub fn init() Enemy {
    return .{
        .health = 100.0,
        .name = "friendly",
        .position = .zero(),
        .velocity = Vector{ .u = 12.0, .v = 7.0 },
    };
}

pub fn physicsStep(self: *Enemy) void {
    self.position.previous = self.position.current;
    self.position.current = self.position.current.addScaled(self.velocity, physics_step_seconds);
}

pub fn draw(self: *const Enemy, alpha: f64) void {
    debug.printEnemy(self, alpha);
}
