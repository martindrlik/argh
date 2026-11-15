pub const Engine = @import("Engine.zig");
pub const Entity = @import("Entity.zig").Entity;
pub const GameLayer = @import("GameLayer.zig");
pub const Layer = @import("layer.zig").Layer;
pub const Platfrom = @import("Platform.zig");
pub const Player = @import("Player.zig");
pub const rl = @import("rl.zig");
pub const screen = @import("screen.zig");
pub const World = @import("World.zig");

pub const float = f64;

pub const Vector = struct {
    h: float,
    v: float,

    pub const zero: Vector = .{ .h = 0.0, .v = 0.0 };

    pub fn new(h: float, v: float) Vector {
        return .{ .h = h, .v = v };
    }

    pub fn fromScreenVector(vector: screen.Vector) Vector {
        return .{
            .h = @floatFromInt(vector.h),
            .v = @floatFromInt(vector.v),
        };
    }

    pub fn addScaled(self: Vector, other: Vector, scale: float) Vector {
        return .{
            .h = self.h + other.h * scale,
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
            .h = @intFromFloat(@round(self.previous.h + (self.current.h - self.previous.h) * alpha)),
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
            .x = @floatFromInt(pt.h),
            .y = @floatFromInt(pt.v),
            .width = @floatFromInt(size.h),
            .height = @floatFromInt(size.v),
        };
    }
};

pub const HCollision = union(enum) {
    left: float,
    right: float,
};

pub const VCollision = union(enum) {
    ceiling: float,
    ground: float,
};
