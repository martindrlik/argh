const std = @import("std");
const Duration = std.Io.Duration;

const Enemy = @import("Enemy.zig");
const Entities = @import("Entity.zig");
const Player = @import("Player.zig");
const Position = @import("Position.zig");

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

pub fn printPlayer(player: *const Player, alpha: f64) void {
    std.debug.print("player:\n", .{});
    if (player.is_grounded) {
        std.debug.print("player is grounded\n", .{});
    } else if (player.is_airborne) {
        std.debug.print("player is airborne\n", .{});
    }
    printIndentedPosition(player.position, alpha);
}

pub fn printEnemy(enemy: *const Enemy, alpha: f64) void {
    std.debug.print("enemy name: {s}\n", .{enemy.name});
    printIndentedPosition(enemy.position, alpha);
}

fn printIndentedPosition(position: Position, alpha: f64) void {
    std.debug.print(
        "\tprevious position: ({}, {})\n",
        .{
            position.previous.u,
            position.previous.v,
        },
    );
    std.debug.print(
        "\tcurrent position: ({}, {})\n",
        .{
            position.current.u,
            position.current.v,
        },
    );

    const draw_point = position.calculateDrawScreenPoint(alpha);
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

pub fn printPlayerJumpRequestConsumed() void {
    std.debug.print("player consumed the jump request\n", .{});
}

pub fn printPlayerLandRequestConsumed() void {
    std.debug.print("player consumed the land request\n", .{});
}

pub fn printPlayerJumped() void {
    std.debug.print("player jumped\n", .{});
}

pub fn printPlayerLanded() void {
    std.debug.print("player landed\n", .{});
}
