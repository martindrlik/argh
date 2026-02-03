const Position = @This();

previous: Vector,
current: Vector,

pub fn zero() Position {
    return .{
        .previous = .zero(),
        .current = .zero(),
    };
}

pub fn calculateDrawScreenPoint(self: *const Position, alpha: f64) ScreenPoint {
    return .{
        .u = @intFromFloat(@round(self.previous.u + (self.current.u - self.previous.u) * alpha)),
        .v = @intFromFloat(@round(self.previous.v + (self.current.v - self.previous.v) * alpha)),
    };
}

pub const Vector = struct {
    u: f64,
    v: f64,

    pub fn zero() Vector {
        return .{ .u = 0.0, .v = 0.0 };
    }

    pub fn addScaled(self: Vector, other: Vector, scale: f64) Vector {
        return .{
            .u = self.u + other.u * scale,
            .v = self.v + other.v * scale,
        };
    }
};

const ScreenPoint = struct {
    u: u32,
    v: u32,
};
