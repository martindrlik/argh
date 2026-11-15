const core = @import("core.zig");
const float = core.float;
const GameLayer = core.GameLayer;
const Entity = core.Entity;
const HCollision = core.HCollision;
const VCollision = core.VCollision;
pub const Layer = @import("layer.zig").Layer;

const World = @This();

layers: [1]Layer,

pub fn queryMut(self: *World, comptime T: type) ?*T {
    for (&self.layers) |*layer| switch (layer.*) {
        .game => |*game| {
            if (game.queryMut(T)) |match| {
                return match;
            }
        },
    };
    return null;
}

pub fn physicsStep(self: *World) void {
    for (&self.layers) |*layer| switch (layer.*) {
        .game => |*game| game.physicsStep(),
    };
}

pub fn draw(self: *const World, alpha: f64) void {
    for (&self.layers) |*layer| switch (layer.*) {
        .game => |game| game.draw(alpha),
    };
}
