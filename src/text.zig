const argh = @import("root.zig");

pub const fontSize = enum(c_int) {
    medium = 20,
    large = 40,
};

pub fn static(comptime text: [*c]const u8, x: c_int, y: c_int, font_size: fontSize) type {
    return struct {
        pub fn draw(_: *const @This()) void {
            argh.drawText(
                text,
                x,
                y,
                @intFromEnum(font_size),
                argh.raywhite,
            );
        }
    };
}
