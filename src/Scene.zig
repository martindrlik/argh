pub const Enemy = @import("Enemy.zig");
pub const Engine = @import("Engine.zig");
pub const Entity = @import("Entity.zig").Entity;
pub const GameScene = @import("GameScene.zig");
pub const Platform = @import("Platform.zig");
pub const Player = @import("Player.zig");

pub const Scene = union(enum) {
    game: GameScene,

    pub fn isActive(self: *Scene) bool {
        return switch (self) {
            .game => true,
        };
    }

    pub fn physicsStep(self: *Scene) void {
        switch (self.*) {
            .game => |*game| game.physicsStep(),
        }
    }

    pub fn draw(self: *const Scene, alpha: f64) void {
        switch (self.*) {
            .game => |game| game.draw(alpha),
        }
    }
};
