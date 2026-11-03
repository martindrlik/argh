const Entity = @import("Entity.zig").Entity;
const Input = @import("Input.zig");

pub const Scene = union(enum) {
    game: GameScene,

    pub fn physicsStep(self: *Scene, input: *Input) void {
        switch (self.*) {
            .game => |*game| {
                game.physicsStep(input);
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
                Entity{ .enemy = .init() },
                Entity{ .player = .init() },
            },
        };
    }

    pub fn physicsStep(self: *GameScene, input: *Input) void {
        for (&self.entities) |*entity| {
            entity.physicsStep(input);
        }
    }

    pub fn draw(self: *const GameScene, alpha: f64) void {
        for (self.entities) |entity| {
            entity.draw(alpha);
        }
    }
};
