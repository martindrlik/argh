const Position = @import("Position.zig");
const Vector = Position.Vector;
const Engine = @import("Engine.zig");
const physics_step_seconds = Engine.physics_step_seconds;
const debug = @import("debug.zig");

pub const Entity = union(enum) {
    enemy: Enemy,

    pub fn physicsStep(self: *Entity) void {
        switch (self.*) {
            .enemy => |*enemy| {
                enemy.physicsStep();
            },
        }
    }

    pub fn draw(self: *const Entity, alpha: f64) void {
        switch (self.*) {
            .enemy => |*enemy| {
                debug.printEnemy(enemy, alpha);
            },
        }
    }
};

pub const Enemy = struct {
    name: []const u8,
    position: Position,
    velocity: Vector,
    health: u32,

    pub fn init() Enemy {
        return .{
            .name = "friendly",
            .position = .zero(),
            .velocity = Vector{ .u = 12.0, .v = 7.0 },
            .health = 100.0,
        };
    }

    pub fn physicsStep(self: *Enemy) void {
        self.position.previous = self.position.current;
        self.position.current = self.position.current.addScaled(self.velocity, physics_step_seconds);
    }
};
