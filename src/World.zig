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

        const player_center_x = rec.x + rec.width / 2;
        const dead_zone_half_width: rl.float = 80;

        const left = self.camera.target.x - dead_zone_half_width;
        const right = self.camera.target.x + dead_zone_half_width;

        if (player_center_x < left) {
            self.camera.target.x = player_center_x + dead_zone_half_width;
        } else if (player_center_x > right) {
            self.camera.target.x = player_center_x - dead_zone_half_width;
        }

        self.camera.target.y = rec.y + rec.height / 2;
    }

    self.clampCamera();

    rl.beginMode2D(self.camera);
    defer rl.endMode2D();

    for (&self.layers) |*layer| switch (layer.*) {
        .game => |game| game.draw(alpha),
    };
}

fn clampCamera(self: *World) void {
    const map_width: rl.float = @floatFromInt(screen.Vector.map_tile_size.h * screen.Vector.tile.h);
    const map_height: rl.float = @floatFromInt(screen.Vector.map_tile_size.v * screen.Vector.tile.v);

    const screen_width: rl.float = @floatFromInt(screen.Vector.screen.h);
    const screen_height: rl.float = @floatFromInt(screen.Vector.screen.v);

    const half_width = screen_width / (2 * self.camera.zoom);
    const half_height = screen_height / (2 * self.camera.zoom);

    self.camera.target.x = if (map_width <= 2 * half_width)
        map_width / 2
    else
        std.math.clamp(
            self.camera.target.x,
            half_width,
            map_width - half_width,
        );

    self.camera.target.y = if (map_height <= 2 * half_height)
        map_height / 2
    else
        std.math.clamp(
            self.camera.target.y,
            half_height,
            map_height - half_height,
        );
}
