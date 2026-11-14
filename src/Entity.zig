const core = @import("core.zig");
const float = core.float;
const Scene = core.Scene;
const Enemy = core.Enemy;
const Engine = core.Engine;
const physics_step_seconds = Engine.physics_step_seconds;
const Platform = core.Platfrom;
const ScreenVector = core.ScreenVector;
const Player = core.Player;
const Position = core.Position;
const Vector = core.Vector;

pub const Entity = union(enum) {
    enemy: Enemy,
    player: Player,
    platform: Platform,

    pub fn physicsStep(self: *Entity, scene: *Scene) void {
        switch (self.*) {
            .enemy => |*enemy| enemy.physicsStep(),
            .player => |*player| player.physicsStep(scene),
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

    pub fn position(self: *const Entity) Position {
        return switch (self.*) {
            .enemy => |enemy| enemy.position,
            .player => |player| player.position,
            .platform => |platform| platform.position,
        };
    }

    pub fn size(self: *const Entity) ScreenVector {
        return switch (self.*) {
            .enemy => .small,
            .player => Player.size,
            .platform => |platform| platform.size,
        };
    }
};
