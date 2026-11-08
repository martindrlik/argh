const rl = @import("raylib");

const core = @import("core.zig");
const Position = core.Position;
const Vector = core.Vector;
const Engine = @import("Engine.zig");
const physics_step_seconds = Engine.physics_step_seconds;

const Enemy = @This();

health: u32,
name: []const u8,
position: Position,
velocity: Vector,

pub const default: Enemy = .{
    .health = 100.0,
    .name = "friendly",
    .position = .zero,
    .velocity = .zero,
};

pub fn physicsStep(self: *Enemy) void {
    self.position.previous = self.position.current;
    self.position.current = self.position.current.addScaled(self.velocity, physics_step_seconds);
}

pub fn draw(self: *const Enemy, alpha: f64) void {
    const rec = self.position.screenRectangle(.{ .u = 64, .v = 64 }, alpha);
    rl.drawRectangleRec(rec, .red);
}
