const core = @import("core.zig");
const Position = core.Position;
const float = core.float;
const Enemy = core.Enemy;
const Engine = core.Engine;
const Entity = core.Entity;
const Player = core.Player;

const GameScene = @This();

entities: [3]Entity,
gravity: float,

pub fn init() GameScene {
    var player = Player.default;
    player.position = .new(.new(Engine.size.u - Player.size.u, 0));

    return .{
        .entities = .{
            Entity{ .enemy = .default },
            Entity{ .player = player },
            Entity{ .platform = .bottomScreen() },
        },
        .gravity = 10,
    };
}

pub fn queryMutEntity(self: *GameScene, comptime T: type) ?*T {
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

pub fn physicsStep(self: *GameScene) void {
    for (&self.entities) |*entity| {
        entity.physicsStep(self.gravity);
    }
}

pub fn draw(self: *const GameScene, alpha: f64) void {
    for (self.entities) |entity| {
        entity.draw(alpha);
    }
}
