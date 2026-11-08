const core = @import("core.zig");
const Enemy = @import("Enemy.zig");
const Engine = @import("Engine.zig");
const physics_step_seconds = Engine.physics_step_seconds;
const Platform = @import("Platform.zig");
const Player = @import("Player.zig");

pub const Entity = union(enum) {
    enemy: Enemy,
    player: Player,
    platform: Platform,

    pub fn physicsStep(self: *Entity) void {
        switch (self.*) {
            .enemy => |*enemy| enemy.physicsStep(),
            .player => |*player| player.physicsStep(),
            .platform => |*platform| platform.physicsStep(),
        }
    }

    pub fn draw(self: *const Entity, alpha: f64) void {
        switch (self.*) {
            .enemy => |*enemy| enemy.draw(alpha),
            .player => |*player| player.draw(alpha),
            .platform => |*platform| platform.draw(alpha),
        }
    }
};
