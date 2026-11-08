const std = @import("std");
const Io = std.Io;
const Duration = std.Io.Duration;

const Engine = @import("Engine.zig");
const physics_step = Engine.physics_step;

const Input = @This();
is_land_requested: bool = false,
stdin_buffer: [2000]u8 = undefined,

pub fn takeLine(self: *Input, io: Io) ?[]u8 {
    var stdin_reader = std.Io.File.stdin().reader(io, &self.stdin_buffer);
    const stdin = &stdin_reader.interface;

    return stdin.takeDelimiter('\n') catch |err| {
        std.debug.print("failed to read stdin: {}\n", .{err});
        return null;
    };
}

pub fn isQuit(line: []const u8) bool {
    return std.mem.eql(u8, line, "quit");
}

pub fn isJump(line: []const u8) bool {
    return std.mem.eql(u8, line, "jump");
}

pub fn isLand(line: []const u8) bool {
    return std.mem.eql(u8, line, "land");
}

pub fn consumeLandRequest(self: *Input) bool {
    return consumeFlag(&self.is_land_requested);
}

fn consumeFlag(flag: *bool) bool {
    if (flag.*) {
        flag.* = false;
        return true;
    }
    return false;
}
