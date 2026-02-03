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
    entities: [1]Entity,

    pub fn init() GameScene {
        return .{ .entities = @splat(Entity{ .enemy = .init() }) };
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
