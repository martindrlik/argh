const rl = @import("raylib");

const core = @import("core.zig");
const screen = core.screen;
const Position = core.Position;
const float = core.float;
const Engine = core.Engine;

const Platfrom = @This();

position: Position,
size: screen.Vector,

pub fn bottomScreen() Platfrom {
    return .{
        .position = .new(.new(0, screen.Vector.screen.v - screen.Vector.small.v)),
        .size = .new(screen.Vector.screen.u, screen.Vector.small.v),
    };
}

pub fn physicsStep(self: *Platfrom) void {
    _ = self;
}

pub fn draw(self: *const Platfrom, alpha: float) void {
    const rec = self.position.screenRectangle(self.size, alpha);
    rl.drawRectangleRec(rec, .gray);
}
