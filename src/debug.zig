const std = @import("std");
const Duration = std.Io.Duration;
const Entities = @import("Entity.zig");
const Enemy = Entities.Enemy;

pub fn printAccumulator(accumulator: Duration) void {
    std.debug.print("accumulator: {}\n", .{durationDisplay(accumulator)});
}

pub fn printElapsed(elapsed: Duration) void {
    std.debug.print("elapsed: {}\n", .{durationDisplay(elapsed)});
}

fn durationDisplay(duration: Duration) f64 {
    const duration_ns: f64 = @floatFromInt(duration.nanoseconds);
    return duration_ns / std.time.ns_per_s;
}

pub fn printAlpha(alpha: f64) void {
    std.debug.print("alpha: {}\n", .{alpha});
}

pub fn printEnemy(enemy: *const Enemy, alpha: f64) void {
    std.debug.print("enemy name: {s}\n", .{enemy.name});
    std.debug.print(
        "\tprevious position: ({}, {})\n",
        .{
            enemy.position.previous.u,
            enemy.position.previous.v,
        },
    );
    std.debug.print(
        "\tcurrent position: ({}, {})\n",
        .{
            enemy.position.current.u,
            enemy.position.current.v,
        },
    );

    const draw_point = enemy.position.calculateDrawScreenPoint(alpha);
    std.debug.print(
        "\tdraw screen position: ({}, {})\n",
        .{
            draw_point.u,
            draw_point.v,
        },
    );
}

pub fn printPhysicsStepOmitted() void {
    std.debug.print("physics step omitted\n", .{});
}
