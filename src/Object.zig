const argh = @import("root.zig");
const V = @import("Vec.zig");
const S = @import("State.zig");

const O = @This();

state: S,
animation: ?[]const S = null,
size: V,
color: argh.Color,

pub fn object(
    state: S,
    size: V,
    color: argh.Color,
) O {
    return .{
        .state = state,
        .size = size,
        .color = color,
    };
}

pub fn setSequence(o: *O, animation: ?[]const S) void {
    o.animation = animation;
}

pub fn update(o: *O) void {
    if (o.animation) |anim| if (anim.len > 0) {
        o.state = .next(o.state, anim[0]);
        if (S.equal(o.state, anim[0])) {
            o.setSequence(anim[1..]);
        }
    };
}

pub fn isSequenceComplete(o: *const O) bool {
    if (o.animation) |anim| if (anim.len > 0) return false;
    return true;
}

pub fn draw(o: *const O) void {
    argh.drawRectangleRec(o.rect(), o.color);
}

pub fn rect(o: *const O) argh.Rectangle {
    return .{
        .x = o.state.pos.x,
        .y = o.state.pos.y,
        .width = o.size.x,
        .height = o.size.y,
    };
}
