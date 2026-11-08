const core = @import("core.zig");
const Position = core.Position;
const Enemy = @import("Enemy.zig");
const Engine = @import("Engine.zig");
const Entity = @import("Entity.zig").Entity;
const Player = @import("Player.zig");

pub const Scene = union(enum) {
    game: GameScene,

    pub fn physicsStep(self: *Scene) void {
        switch (self.*) {
            .game => |*game| {
                game.physicsStep();
            },
        }
    }

    pub fn draw(self: *const Scene, alpha: f64) void {
        switch (self.*) {
            .game => |game| {
                game.draw(alpha);
            },
        }
    }
};

const GameScene = struct {
    entities: [3]Entity,

    pub fn init() GameScene {
        var player = Player.default;
        player.position = .new(.new(Engine.size.u - Player.size.u, 0));

        return .{
            .entities = .{
                Entity{ .enemy = .default },
                Entity{ .player = player },
                Entity{ .platform = .bottomScreen() },
            },
        };
    }

    pub fn physicsStep(self: *GameScene) void {
        for (&self.entities) |*entity| {
            entity.physicsStep();
        }
    }

    pub fn draw(self: *const GameScene, alpha: f64) void {
        for (self.entities) |entity| {
            entity.draw(alpha);
        }
    }
};
