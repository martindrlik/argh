pub const int = i64;

pub const Vector = struct {
    h: int,
    v: int,

    pub const tile: Vector = .new(32, 32);
    pub const screen: Vector = .new(1024, 768);
    pub const map_tile_size = Vector.new(81, 24);

    pub fn new(h: int, v: int) Vector {
        return .{ .h = h, .v = v };
    }
};
