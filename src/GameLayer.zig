const std = @import("std");
const Io = std.Io;

const core = @import("core.zig");
const Layer = core.Layer;
const Position = core.Position;
const float = core.float;
const Engine = core.Engine;
const Entity = core.Entity;
const Player = core.Player;
const screen = core.screen;
const loader = @import("loader.zig");

const GameLayer = @This();

entities: [screen.Vector.tiles.h * screen.Vector.tiles.v]Entity,
gravity: float,

pub fn load(io: Io, file_path: []const u8) !GameLayer {
    var game = GameLayer{
        .entities = undefined,
        .gravity = 500,
    };
    try loader.loadGameLevel(io, file_path, &game);
    return game;
}

pub fn queryMut(self: *GameLayer, comptime T: type) ?*T {
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

pub fn parentLayer(self: *GameLayer) *Layer {
    return @fieldParentPtr("game", self);
}

pub fn physicsStep(self: *GameLayer) void {
    const layer = self.parentLayer();
    for (&self.entities) |*entity| {
        entity.physicsStep(layer);
    }
}

pub fn draw(self: *const GameLayer, alpha: f64) void {
    for (self.entities) |entity| {
        entity.draw(alpha);
    }
}
