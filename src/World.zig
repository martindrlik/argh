const std = @import("std");
const Io = std.Io;

const core = @import("core.zig");
const Entity = core.Entity;
const GameLayer = core.GameLayer;
const HCollision = core.HCollision;
const Layer = core.Layer;
const Player = core.Player;
const Position = core.Position;
const VCollision = core.VCollision;
const float = core.float;
const rl = core.rl;
const screen = core.screen;
const Camera2D = rl.Camera2D;

const World = @This();

camera: Camera2D,
layers: [1]Layer,

pub fn init(io: Io, level_file_path: []const u8) !World {
    var world: World = .{
        .camera = cameraInit(),
        .layers = .{
            .{ .game = try .load(io, level_file_path) },
        },
    };

    if (world.queryMut(Player)) |player| {
        world.cameraSnapTo(player.position, player.properties.size);
    }

    world.cameraClamp(screen.Vector.screen);

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
        self.cameraFollow(
            player.position,
            player.properties.size,
            alpha,
            elapsed_seconds,
        );
    }

    self.cameraClamp(screen.Vector.screen);

    rl.beginMode2D(self.camera);
    defer rl.endMode2D();

    for (&self.layers) |*layer| switch (layer.*) {
        .game => |game| game.draw(alpha),
    };
}

pub fn cameraInit() Camera2D {
    const size = core.Vector.fromScreenVector(screen.Vector.screen);
    return .{
        .offset = .{
            .x = @floatCast(size.h / 2),
            .y = @floatCast(size.v / 2),
        },
        .target = .{ .x = 0, .y = 0 },
        .rotation = 0,
        .zoom = 1,
    };
}

pub fn cameraSnapTo(
    self: *World,
    entity_position: Position,
    entity_size: screen.Vector,
) void {
    const size = core.Vector.fromScreenVector(entity_size);
    self.camera.target = .{
        .x = @floatCast(entity_position.current.h + size.h / 2),
        .y = @floatCast(entity_position.current.v + size.v / 2),
    };
}

pub fn cameraFollow(
    self: *World,
    entity_position: Position,
    entity_size: screen.Vector,
    alpha: float,
    elapsed_seconds: float,
) void {
    const rec = entity_position.screenRectangle(entity_size, alpha);

    var desired = self.camera.target;

    const entity_center_x = rec.x + rec.width / 2;
    const dead_zone_half_width: rl.float = 80;

    const left = self.camera.target.x - dead_zone_half_width;
    const right = self.camera.target.x + dead_zone_half_width;

    if (entity_center_x < left) {
        desired.x = entity_center_x + dead_zone_half_width;
    } else if (entity_center_x > right) {
        desired.x = entity_center_x - dead_zone_half_width;
    }

    const entity_center_y = rec.y + rec.height / 2;
    const top = self.camera.target.y - 100;
    const bottom = self.camera.target.y + 60;

    if (entity_center_y < top) {
        desired.y = entity_center_y + 100;
    } else if (entity_center_y > bottom) {
        desired.y = entity_center_y - 60;
    }

    const follow_speed: float = 8;
    const weight: rl.float =
        @floatCast(1 - @exp(-follow_speed * elapsed_seconds));

    self.camera.target.x +=
        (desired.x - self.camera.target.x) * weight;
    self.camera.target.y +=
        (desired.y - self.camera.target.y) * weight;
}

pub fn cameraClamp(
    self: *World,
    screen_size: screen.Vector,
) void {
    const map_width: rl.float = @floatCast(core.Vector.map_size.h);
    const map_height: rl.float = @floatCast(core.Vector.map_size.v);

    const screen_width: rl.float = @floatFromInt(screen_size.h);
    const screen_height: rl.float = @floatFromInt(screen_size.v);

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
