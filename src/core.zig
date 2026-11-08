const rl = @import("raylib");

pub const float = f64;
pub const int = i64;
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

pub const ScreenVector = struct {
    u: int,
    v: int,

    pub const small: ScreenVector = .new(64, 64);

    pub fn new(u: int, v: int) ScreenVector {
        return .{ .u = u, .v = v };
    }
};

pub const Position = struct {
    previous: Vector,
    current: Vector,

    pub const zero: Position = .{ .current = .zero, .previous = .zero };

    pub fn new(position: Vector) Position {
        return .{ .previous = position, .current = position };
    }

    pub fn screenPosition(self: *const Position, alpha: float) ScreenVector {
        return .{
            .u = @intFromFloat(@round(self.previous.u + (self.current.u - self.previous.u) * alpha)),
            .v = @intFromFloat(@round(self.previous.v + (self.current.v - self.previous.v) * alpha)),
        };
    }

    pub fn screenRectangle(
        self: *const Position,
        size: ScreenVector,
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
