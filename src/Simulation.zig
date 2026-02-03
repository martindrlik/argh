const std = @import("std");
const Io = std.Io;
const Random = std.Random;
const Duration = std.Io.Duration;
const Engine = @import("Engine.zig");
const physics_step = Engine.physics_step;

const Self = @This();

prng: Random.DefaultPrng,

pub fn init(seed: u64) Self {
    return .{
        .prng = std.Random.DefaultPrng.init(seed),
    };
}

pub fn float(self: *Self, comptime T: type) T {
    return self.prng.random().float(T);
}

test "float is in range" {
    var simulation: Self = .init(32);
    const value = simulation.float(f32);
    try std.testing.expect(value >= 0.0);
    try std.testing.expect(value < 1.0);
}

pub fn elapsed(self: *Self) Duration {
    return self.durationRangeAtMost(.fromNanoseconds(0), .fromNanoseconds(2 * physics_step.nanoseconds));
}

fn durationRangeAtMost(self: *Self, at_least: Duration, at_most: Duration) Duration {
    return .{
        .nanoseconds = self.prng.random().intRangeAtMost(
            i96,
            at_least.nanoseconds,
            at_most.nanoseconds,
        ),
    };
}
