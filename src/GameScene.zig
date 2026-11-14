const std = @import("std");
const Io = std.Io;

const core = @import("core.zig");
const Position = core.Position;
const float = core.float;
const Engine = core.Engine;
const Entity = core.Entity;
const Player = core.Player;
const Scene = core.Scene;
const screen = core.screen;
const loader = @import("loader.zig");

const GameScene = @This();

entities: [screen.Vector.tiles.u * screen.Vector.tiles.v]Entity,
gravity: float,

pub fn load(io: Io, file_path: []const u8) !GameScene {
    var game_scene = GameScene{
        .entities = undefined,
        .gravity = 500,
    };
    try loader.loadGameScene(io, file_path, &game_scene);
    return game_scene;
}

pub fn queryMut(self: *GameScene, comptime T: type) ?*T {
    for (&self.entities) |*entity| {
        switch (entity.*) {
            inline else => |*payload| {
                if (@TypeOf(payload) == *T) {
                    return payload;
                }
            },
        }
    }
    return null;
}

pub fn physicsStep(self: *GameScene, scene: *Scene) void {
    for (&self.entities) |*entity| {
        entity.physicsStep(scene);
    }
}

pub fn draw(self: *const GameScene, alpha: f64) void {
    for (self.entities) |entity| {
        entity.draw(alpha);
    }
}
