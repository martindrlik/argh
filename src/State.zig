const std = @import("std");
const V = @import("Vec.zig");
const S = @This();

pos: V = .z,
vel: V = .z,
size: V = .big,
origin: V = .center,

pub fn init(pos: V) S {
    return .{
        .pos = pos,
    };
}

pub fn slow(s: S) S {
    s.vel = .slow;
    return s;
}

pub fn fast(s: S) S {
    s.vel = .fast;
    return s;
}

pub fn sonic(s: S) S {
    var t = s;
    t.vel = .sonic;
    return t;
}

pub fn small(s: S) S {
    var t = s;
    t.size = .small;
    return t;
}

pub fn screen(s: S) S {
    var t = s;
    t.size = .screen;
    return t;
}

pub fn next(u: S, v: S) S {
    // TODO need animation redesign
    return .{
        .pos = .next(u.pos, v.pos, v.vel),
        .size = .next(u.size, v.size, v.vel),
        .vel = u.vel,
    };
}

pub fn equal(u: S, v: S) bool {
    return V.equal(u.pos, v.pos);
}
