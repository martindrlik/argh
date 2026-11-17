const core = @import("core.zig");
const float = core.float;
const GameLayer = core.GameLayer;
const Entity = core.Entity;
const HCollision = core.HCollision;
const VCollision = core.VCollision;

pub const Layer = union(enum) {
    game: GameLayer,

    pub fn entities(self: *const Layer) []const Entity {
        return switch (self.*) {
            .game => |*game| &game.entities,
        };
    }

    pub fn physicsStep(self: *Layer) void {
        switch (self.*) {
            .game => |*game| game.physicsStep(self),
        }
    }

    pub fn horizontalCollision(self: *const Layer, entity: *const Entity) ?HCollision {
        const entity_position = entity.position();
        const entity_width: float = @floatFromInt(entity.size().h);
        const entity_height: float = @floatFromInt(entity.size().v);
        const entity_bottom: float = entity_position.current.v + entity_height;

        var nearest: ?float = null;
        for (self.entities()) |*other| {
            if (entity == other) {
                continue;
            }
            const other_position = other.position();
            const other_width: float = @floatFromInt(other.size().h);
            const other_height: float = @floatFromInt(other.size().v);
            const other_right = other_position.current.h + other_width;
            const other_bottom = other_position.current.v + other_height;

            // we need vertical overlap
            if (entity_bottom <= other_position.current.v or
                entity_position.current.v >= other_bottom)
            {
                continue;
            }

            if (entity_position.previous.h < entity_position.current.h) {
                const previous_right = entity_position.previous.h + entity_width;
                const current_right = entity_position.current.h + entity_width;

                if (previous_right <= other_position.current.h and
                    current_right >= other_position.current.h)
                {
                    const surface = other_position.current.h;
                    nearest = if (nearest) |previous| @min(previous, surface) else surface;
                }
            } else if (entity_position.previous.h > entity_position.current.h) {
                if (entity_position.previous.h >= other_right and
                    entity_position.current.h <= other_right)
                {
                    nearest = if (nearest) |previous| @max(previous, other_right) else other_right;
                }
            }
        }
        if (nearest) |surface| {
            return if (entity_position.current.h > entity_position.previous.h)
                .{ .left = surface }
            else
                .{ .right = surface };
        }
        return null;
    }

    pub fn verticalCollision(
        self: *const Layer,
        entity: *const Entity,
        start_v: float,
    ) ?VCollision {
        const entity_position = entity.position();
        const entity_width: float = @floatFromInt(entity.size().h);
        const entity_height: float = @floatFromInt(entity.size().v);
        const entity_right = entity_position.current.h + entity_width;

        var nearest: ?float = null;
        for (self.entities()) |*other| {
            if (entity == other) {
                continue;
            }
            const other_position = other.position();
            const other_width: float = @floatFromInt(other.size().h);
            const other_height: float = @floatFromInt(other.size().v);
            const other_right = other_position.current.h + other_width;
            const other_bottom = other_position.current.v + other_height;

            // we need horizontal overlap
            if (entity_right <= other_position.current.h or
                entity_position.current.h >= other_right)
            {
                continue;
            }

            if (start_v < entity_position.current.v) {
                const previous_bottom = start_v + entity_height;
                const current_bottom = entity_position.current.v + entity_height;

                if (previous_bottom <= other_position.current.v and
                    current_bottom >= other_position.current.v)
                {
                    const surface = other_position.current.v;
                    nearest = if (nearest) |previous| @min(previous, surface) else surface;
                }
            } else if (start_v > entity_position.current.v) {
                if (start_v >= other_bottom and
                    entity_position.current.v <= other_bottom)
                {
                    nearest = if (nearest) |previous| @max(previous, other_bottom) else other_bottom;
                }
            }
        }
        if (nearest) |surface| {
            return if (entity_position.current.v > start_v)
                .{ .ground = surface }
            else
                .{ .ceiling = surface };
        }
        return null;
    }

    pub fn draw(self: *const Layer, alpha: f64) void {
        switch (self.*) {
            .game => |game| game.draw(alpha),
        }
    }
};
