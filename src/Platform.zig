const rl = @import("raylib");

const core = @import("core.zig");
const screen = core.screen;
const Position = core.Position;
const float = core.float;

const Platfrom = @This();

position: Position,
size: screen.Vector,

pub fn physicsStep(self: *Platfrom) void {
    _ = self;
}

pub fn draw(self: *const Platfrom, alpha: float) void {
    const rec = self.position.screenRectangle(self.size, alpha);
    rl.drawRectangleRec(rec, .gray);
}
