const core = @import("core.zig");
const Enemy = @import("Enemy.zig");
const Engine = @import("Engine.zig");
const physics_step_seconds = Engine.physics_step_seconds;
const Player = @import("Player.zig");

pub const Entity = union(enum) {
    enemy: Enemy,
    player: Player,

    pub fn physicsStep(self: *Entity) void {
        switch (self.*) {
            .enemy => |*enemy| enemy.physicsStep(),
            .player => |*player| player.physicsStep(),
        }
    }

    pub fn draw(self: *const Entity, alpha: f64) void {
        switch (self.*) {
            .enemy => |*enemy| enemy.draw(alpha),
            .player => |*player| player.draw(alpha),
        }
    }
};
