const std = @import("std");

const core = @import("core.zig");
const float = core.float;
const rl = core.rl;
const screen = core.screen;
const Camera2D = rl.Camera2D;
const Position = core.Position;

const Camera = @This();

camera: Camera2D,

pub fn init() Camera {
    const screen_width: rl.float = @floatFromInt(screen.Vector.screen.h);
    const screen_height: rl.float = @floatFromInt(screen.Vector.screen.v);
    return .{
        .camera = .{
            .offset = .{
                .x = @floatCast(screen_width / 2),
                .y = @floatCast(screen_height / 2),
            },
            .target = .{ .x = 0, .y = 0 },
            .rotation = 0,
            .zoom = 1,
        },
    };
}

pub fn snapToEntity(
    self: *Camera,
    entity_position: Position,
    entity_size: screen.Vector,
) void {
    const size = core.Vector.fromScreenVector(entity_size);

    self.camera.target = .{
        .x = @floatCast(entity_position.current.h + size.h / 2),
        .y = @floatCast(entity_position.current.v + size.v / 2),
    };
}

pub fn followEntity(
    self: *Camera,
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

pub fn clamp(self: *Camera, screen_size: screen.Vector, map_size: core.Vector) void {
    const map_width: rl.float = @floatCast(map_size.h);
    const map_height: rl.float = @floatCast(map_size.v);

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
