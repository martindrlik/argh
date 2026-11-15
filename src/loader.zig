const std = @import("std");
const Io = std.Io;

const core = @import("core.zig");
const GameLayer = core.GameLayer;
const Player = core.Player;
const Platform = core.Platfrom;
const Position = core.Position;
const screen = core.screen;

pub fn loadGameLevel(io: Io, file_path: []const u8, layer: *GameLayer) !void {
    var buffer: [screen.Vector.map_tile_size.h * screen.Vector.map_tile_size.v + screen.Vector.map_tile_size.v]u8 = undefined;
    const map = try std.Io.Dir.cwd().readFile(io, file_path, &buffer);
    var lines = std.mem.splitScalar(u8, map, '\n');

    var current_u: core.float = 0;
    var current_v: core.float = 0;
    var entity_id: usize = 0;
    while (lines.next()) |line| {
        for (line) |tile| {
            const position = Position.new(.new(
                current_u * screen.Vector.tile.h,
                current_v * screen.Vector.tile.v,
            ));
            switch (tile) {
                'P' => layer.entities[entity_id] = .{
                    .player = .new(position, true),
                },
                '-' => layer.entities[entity_id] = .{
                    .platform = Platform{
                        .position = position,
                        .size = .tile,
                    },
                },
                'x' => layer.entities[entity_id] = .{
                    .platform = Platform{
                        .position = position,
                        .size = .tile,
                    },
                },
                '|' => layer.entities[entity_id] = .{
                    .platform = Platform{
                        .position = position,
                        .size = .tile,
                    },
                },
                else => {
                    layer.entities[entity_id] = .{ .empty = .{} };
                },
            }
            current_u += 1;
            entity_id += 1;
        }
        current_u = 0;
        current_v += 1;
    }
}
