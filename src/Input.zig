const Input = @This();
const std = @import("std");
const Io = std.Io;

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
