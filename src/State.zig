const std = @import("std");
const V = @import("Vec.zig");
const S = @This();

pos: V,
vel: V,

pub fn state(pos: V, vel: V) S {
    return .{
        .pos = pos,
        .vel = vel,
    };
}

pub fn still(pos: V) S {
    return .state(pos, .zero);
}

pub fn slow(pos: V) S {
    return .state(pos, .slow);
}

pub fn fast(pos: V) S {
    return .state(pos, .fast);
}

pub fn sonic(pos: V) S {
    return .state(pos, .sonic);
}

pub fn next(u: S, v: S) S {
    return .{
        .pos = .next(u.pos, v.pos, v.vel),
        .vel = .next(u.vel, v.vel, .fast), // improve this (acceleration)
    };
}

pub fn equal(u: S, v: S) bool {
    return V.equal(u.pos, v.pos);
}
