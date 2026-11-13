const rl = @import("raylib");

const core = @import("core.zig");
const ScreenVector = core.ScreenVector;
const Position = core.Position;
const float = core.float;
const Engine = core.Engine;

const Platfrom = @This();

position: Position,
size: ScreenVector,

pub fn bottomScreen() Platfrom {
    return .{
        .position = .new(.new(0, Engine.size.v - ScreenVector.small.v)),
        .size = .new(Engine.size.u, ScreenVector.small.v),
    };
}

pub fn physicsStep(self: *Platfrom) void {
    _ = self;
}

pub fn draw(self: *const Platfrom, alpha: float) void {
    const rec = self.position.screenRectangle(self.size, alpha);
    rl.drawRectangleRec(rec, .gray);
}
