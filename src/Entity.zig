const core = @import("core.zig");
const float = core.float;
const Scene = core.Scene;
const Engine = core.Engine;
const physics_step_seconds = Engine.physics_step_seconds;
const Platform = core.Platfrom;
const Player = core.Player;
const Position = core.Position;
const Vector = core.Vector;
const screen = core.screen;

pub const Entity = union(enum) {
    player: Player,
    platform: Platform,
    empty: Empty,

    pub const Empty = struct {};

    pub fn physicsStep(self: *Entity, scene: *Scene) void {
        switch (self.*) {
            .player => |*player| player.physicsStep(scene),
            .platform => |*platform| platform.physicsStep(),
            .empty => {},
        }
    }

    pub fn draw(self: *const Entity, alpha: f64) void {
        switch (self.*) {
            .player => |*player| player.draw(alpha),
            .platform => |*platform| platform.draw(alpha),
            .empty => {},
        }
    }

    pub fn position(self: *const Entity) Position {
        return switch (self.*) {
            .player => |player| player.position,
            .platform => |platform| platform.position,
            .empty => .zero,
        };
    }

    pub fn size(self: *const Entity) screen.Vector {
        return switch (self.*) {
            .player => Player.bounds.size,
            .platform => |platform| platform.size,
            .empty => .tile,
        };
    }
};
