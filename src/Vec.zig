const std = @import("std");

const float = @import("float.zig");
const F = float.F;
const nextf = float.next;

const V = @This();

pub const zero = vec(0, 0);
pub const small = vec(40, 40);
pub const screen = vec(800, 800);

pub const slow = vec(1, 1);
pub const fast = vec(4, 4);
pub const sonic = vec(16, 16);

x: F,
y: F,

pub fn vec(x: F, y: F) V {
    return .{ .x = x, .y = y };
}

pub fn in(size: V, x: F, y: F) V {
    return vec(
        if (x + size.x > screen.x) screen.x - size.x else if (x < 0) 0 else x,
        if (y + size.y > screen.y) screen.y - size.y else if (y < 0) 0 else y,
    );
}

test in {
    const u = in(.small, -100, -100);
    const v = in(.small, screen.x, screen.y);
    try std.testing.expectEqual(zero.x, u.x);
    try std.testing.expectEqual(zero.y, u.y);
    try std.testing.expectEqual(screen.x - small.x, v.x);
    try std.testing.expectEqual(screen.y - small.y, v.y);
}

pub fn next(u: V, v: V, vel: V) V {
    return .{
        .x = nextf(u.x, v.x, vel.x),
        .y = nextf(u.y, v.y, vel.y),
    };
}

test next {
    const one = vec(1, 1);
    try std.testing.expectEqual(vec(4, 5), next(.vec(5, 5), .vec(3, 5), one));
    try std.testing.expectEqual(vec(6, 5), next(.vec(5, 5), .vec(7, 5), one));
    try std.testing.expectEqual(vec(5, 4), next(.vec(5, 5), .vec(5, 3), one));
    try std.testing.expectEqual(vec(5, 6), next(.vec(5, 5), .vec(5, 7), one));
}

pub fn equal(u: V, v: V) bool {
    return u.x == v.x and u.y == v.y;
}

test equal {
    try std.testing.expectEqual(false, equal(vec(4, 5), vec(3, 5)));
    try std.testing.expectEqual(false, equal(vec(4, 5), vec(5, 5)));
    try std.testing.expectEqual(false, equal(vec(4, 5), vec(4, 4)));
    try std.testing.expectEqual(false, equal(vec(4, 5), vec(4, 6)));
    try std.testing.expectEqual(true, equal(vec(4, 5), vec(4, 5)));
}
