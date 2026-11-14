pub const Engine = @import("Engine.zig");
pub const Entity = @import("Entity.zig").Entity;
pub const GameScene = @import("GameScene.zig");
pub const Platfrom = @import("Platform.zig");
pub const Player = @import("Player.zig");
pub const rl = @import("rl.zig");
pub const Scene = @import("scene.zig").Scene;
pub const screen = @import("screen.zig");

pub const float = f64;

pub const Vector = struct {
    u: float,
    v: float,

    pub const zero: Vector = .{ .u = 0.0, .v = 0.0 };

    pub fn new(u: float, v: float) Vector {
        return .{ .u = u, .v = v };
    }

    pub fn addScaled(self: Vector, other: Vector, scale: float) Vector {
        return .{
            .u = self.u + other.u * scale,
            .v = self.v + other.v * scale,
        };
    }
};

pub const Position = struct {
    previous: Vector,
    current: Vector,

    pub const zero: Position = .{ .current = .zero, .previous = .zero };

    pub fn new(position: Vector) Position {
        return .{ .previous = position, .current = position };
    }

    pub fn screenPosition(self: *const Position, alpha: float) screen.Vector {
        return .{
            .u = @intFromFloat(@round(self.previous.u + (self.current.u - self.previous.u) * alpha)),
            .v = @intFromFloat(@round(self.previous.v + (self.current.v - self.previous.v) * alpha)),
        };
    }

    pub fn screenRectangle(
        self: *const Position,
        size: screen.Vector,
        alpha: f64,
    ) rl.Rectangle {
        const pt = self.screenPosition(alpha);
        return .{
            .x = @floatFromInt(pt.u),
            .y = @floatFromInt(pt.v),
            .width = @floatFromInt(size.u),
            .height = @floatFromInt(size.v),
        };
    }
};

pub const HCollision = union(enum) {
    left_wall: float,
    right_wall: float,
};

pub const VCollision = union(enum) {
    ceiling: float,
    ground: float,
};
