pub const float = f64;
pub const unsigned = u64;

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

pub const DrawPoint = struct {
    u: unsigned,
    v: unsigned,
};

pub const Position = struct {
    previous: Vector,
    current: Vector,

    pub const zero: Position = .{ .current = .zero, .previous = .zero };

    pub fn drawPoint(self: *const Position, alpha: float) DrawPoint {
        return .{
            .u = @intFromFloat(@round(self.previous.u + (self.current.u - self.previous.u) * alpha)),
            .v = @intFromFloat(@round(self.previous.v + (self.current.v - self.previous.v) * alpha)),
        };
    }
};
