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
const Camera2D = rl.Camera2D;

const World = @This();

camera: Camera2D,
layers: [1]Layer,

pub fn init(io: Io, level_file_path: []const u8) !World {
    const screen_size = core.Vector.fromScreenVector(screen.Vector.screen);
    return .{
        .camera = .{
            .offset = .{
                .x = @floatCast(screen_size.h / 2),
                .y = @floatCast(screen_size.v / 2),
            },
            .target = .{ .x = 0, .y = 0 },
            .rotation = 0,
            .zoom = 1,
        },
        .layers = @splat(Layer{
            .game = try .load(io, level_file_path),
        }),
    };
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

pub fn draw(self: *World, alpha: float) void {
    if (self.queryMut(Player)) |player| {
        const rec = player.position.screenRectangle(
            player.properties.size,
            alpha,
        );
        self.camera.target = .{
            .x = rec.x + rec.width / 2,
            .y = rec.y + rec.height / 2,
        };
    }

    rl.beginMode2D(self.camera);
    defer rl.endMode2D();

    for (&self.layers) |*layer| switch (layer.*) {
        .game => |game| game.draw(alpha),
    };
}
