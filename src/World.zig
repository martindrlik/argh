const std = @import("std");
const Io = std.Io;

const core = @import("core.zig");
const Entity = core.Entity;
const GameLayer = core.GameLayer;
const HCollision = core.HCollision;
const Layer = core.Layer;
const Player = core.Player;
const VCollision = core.VCollision;
const float = core.float;
const rl = core.rl;
const screen = core.screen;
const Camera = core.Camera;

const map_size: core.Vector = .new(
    screen.Vector.map_tile_size.h * screen.Vector.tile.h,
    screen.Vector.map_tile_size.v * screen.Vector.tile.v,
);

const World = @This();

camera: Camera,
layers: [1]Layer,

pub fn init(io: Io, level_file_path: []const u8) !World {
    var world: World = .{
        .camera = .init(),
        .layers = .{
            .{ .game = try .load(io, level_file_path) },
        },
    };

    if (world.queryMut(Player)) |player| {
        world.camera.snapToEntity(
            player.position,
            player.properties.size,
        );
    }

    world.camera.clamp(
        screen.Vector.screen,
        core.Vector.map_size,
    );

    return world;
}

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

pub fn draw(self: *World, alpha: float, elapsed_seconds: float) void {
    if (self.queryMut(Player)) |player| {
        self.camera.followEntity(
            player.position,
            player.properties.size,
            alpha,
            elapsed_seconds,
        );
    }

    self.camera.clamp(screen.Vector.screen, core.Vector.map_size);

    rl.beginMode2D(self.camera);
    defer rl.endMode2D();

    for (&self.layers) |*layer| switch (layer.*) {
        .game => |game| game.draw(alpha),
    };
}
