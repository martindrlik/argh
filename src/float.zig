const std = @import("std");

pub const F = f32;

pub fn next(u: F, v: F, vel: F) F {
    if (u > v) {
        if (u - @abs(vel) < v) return v;
        return u - @abs(vel);
    } else if (u < v) {
        if (u + @abs(vel) > v) return v;
        return u + @abs(vel);
    } else {
        return u;
    }
}

test next {
    try std.testing.expectEqual(5, next(4, 6, 1));
    try std.testing.expectEqual(3, next(4, 2, 1));
    try std.testing.expectEqual(6, next(4, 6, 3));
    try std.testing.expectEqual(2, next(4, 2, 3));
}
