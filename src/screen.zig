pub const int = i64;

pub const Vector = struct {
    u: int,
    v: int,

    pub const tile: Vector = .new(32, 32);
    pub const screen: Vector = .new(1024, 768);
    pub const tiles = Vector.new(32, 24);

    pub fn new(u: int, v: int) Vector {
        return .{ .u = u, .v = v };
    }
};
