const Entity = @import("Entity.zig").Entity;

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
    entities: [2]Entity,

    pub fn init() GameScene {
        return .{
            .entities = .{
                Entity{ .enemy = .default },
                Entity{ .player = .default },
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
