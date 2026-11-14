const core = @import("core.zig");
const float = core.float;
const VCollision = core.VCollision;
pub const Enemy = @import("Enemy.zig");
pub const Engine = @import("Engine.zig");
pub const Entity = @import("Entity.zig").Entity;
pub const GameScene = @import("GameScene.zig");
pub const Platform = @import("Platform.zig");
pub const Player = @import("Player.zig");

pub const Scene = union(enum) {
    game: GameScene,

    pub fn gravity(self: *Scene) float {
        return switch (self.*) {
            .game => |*game| game.gravity,
        };
    }

    pub fn entities(self: *const Scene) []const Entity {
        return switch (self.*) {
            .game => |*game| &game.entities,
        };
    }

    pub fn physicsStep(self: *Scene) void {
        switch (self.*) {
            .game => |*game| game.physicsStep(self),
        }
    }

    pub fn checkVCollision(self: *const Scene, entity: *const Entity) ?VCollision {
        const entity_position = entity.position();
        const entity_width: float = @floatFromInt(entity.size().u);
        const entity_height: float = @floatFromInt(entity.size().v);
        const entity_right = entity_position.current.u + entity_width;
        for (self.entities()) |*other| {
            if (entity == other) {
                continue;
            }
            const other_position = other.position();
            const other_width: float = @floatFromInt(other.size().u);
            const other_height: float = @floatFromInt(other.size().v);
            const other_right = other_position.current.u + other_width;
            const other_bottom = other_position.current.v + other_height;

            if (entity_right < other_position.current.u or
                entity_position.current.u > other_right)
            {
                continue;
            }

            if (entity_position.previous.v < entity_position.current.v) {
                if (entity_position.current.v + entity_height > other_position.current.v) return .{ .ground = other_position.current.v };
            } else if (entity_position.previous.v > entity_position.current.v) {
                if (entity_position.current.v < other_bottom) return .{ .ceiling = other_bottom };
            }
        }
        return null;
    }

    pub fn draw(self: *const Scene, alpha: f64) void {
        switch (self.*) {
            .game => |game| game.draw(alpha),
        }
    }
};
