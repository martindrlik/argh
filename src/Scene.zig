const core = @import("core.zig");
const float = core.float;
const GameScene = core.GameScene;
const Entity = core.Entity;
const HCollision = core.HCollision;
const VCollision = core.VCollision;

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

    pub fn checkHCollision(self: *const Scene, entity: *const Entity) ?HCollision {
        const entity_position = entity.position();
        const entity_width: float = @floatFromInt(entity.size().u);
        const entity_height: float = @floatFromInt(entity.size().v);
        const entity_bottom: float = entity_position.current.v + entity_height;

        var nearest: ?float = null;
        for (self.entities()) |*other| {
            if (entity == other) {
                continue;
            }
            const other_position = other.position();
            const other_width: float = @floatFromInt(other.size().u);
            const other_height: float = @floatFromInt(other.size().v);
            const other_right = other_position.current.u + other_width;
            const other_bottom = other_position.current.v + other_height;

            // we need vertical overlap
            if (entity_bottom <= other_position.current.v or
                entity_position.current.v >= other_bottom)
            {
                continue;
            }

            if (entity_position.previous.u < entity_position.current.u) {
                const previous_right = entity_position.previous.u + entity_width;
                const current_right = entity_position.current.u + entity_width;

                if (previous_right <= other_position.current.u and
                    current_right >= other_position.current.u)
                {
                    const surface = other_position.current.u;
                    nearest = if (nearest) |previous| @min(previous, surface) else surface;
                }
            } else if (entity_position.previous.u > entity_position.current.u) {
                if (entity_position.previous.u >= other_right and
                    entity_position.current.u <= other_right)
                {
                    nearest = if (nearest) |previous| @max(previous, other_right) else other_right;
                }
            }
        }
        if (nearest) |surface| {
            return if (entity_position.current.u > entity_position.previous.u)
                .{ .left_wall = surface }
            else
                .{ .right_wall = surface };
        }
        return null;
    }

    pub fn checkVCollision(self: *const Scene, entity: *const Entity) ?VCollision {
        const entity_position = entity.position();
        const entity_width: float = @floatFromInt(entity.size().u);
        const entity_height: float = @floatFromInt(entity.size().v);
        const entity_right = entity_position.current.u + entity_width;

        var nearest: ?float = null;
        for (self.entities()) |*other| {
            if (entity == other) {
                continue;
            }
            const other_position = other.position();
            const other_width: float = @floatFromInt(other.size().u);
            const other_height: float = @floatFromInt(other.size().v);
            const other_right = other_position.current.u + other_width;
            const other_bottom = other_position.current.v + other_height;

            // we need horizontal overlap
            if (entity_right <= other_position.current.u or
                entity_position.current.u >= other_right)
            {
                continue;
            }

            if (entity_position.previous.v < entity_position.current.v) {
                const previous_bottom = entity_position.previous.v + entity_height;
                const current_bottom = entity_position.current.v + entity_height;

                if (previous_bottom <= other_position.current.v and
                    current_bottom >= other_position.current.v)
                {
                    const surface = other_position.current.v;
                    nearest = if (nearest) |previous| @min(previous, surface) else surface;
                }
            } else if (entity_position.previous.v > entity_position.current.v) {
                if (entity_position.previous.v >= other_bottom and
                    entity_position.current.v <= other_bottom)
                {
                    nearest = if (nearest) |previous| @max(previous, other_bottom) else other_bottom;
                }
            }
        }
        if (nearest) |surface| {
            return if (entity_position.current.v > entity_position.previous.v)
                .{ .ground = surface }
            else
                .{ .ceiling = surface };
        }
        return null;
    }

    pub fn draw(self: *const Scene, alpha: f64) void {
        switch (self.*) {
            .game => |game| game.draw(alpha),
        }
    }
};
