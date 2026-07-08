const rl = @import("raylib");

pub const EntityTag = enum {
    box,
    text,
};

pub const Entity = union(EntityTag) {
    box: Box,
    text: Text,

    pub fn isSelected(self: *const Entity) bool {
        return switch (self.*) {
            .box => |*box| box.is_selected,
            .text => |*text| text.is_selected,
        };
    }

    pub fn select(self: *Entity, is_selected: bool) void {
        switch (self.*) {
            .box => |*box| box.is_selected = is_selected,
            .text => |*text| text.is_selected = is_selected,
        }
    }

    pub fn draw(self: *const Entity) void {
        switch (self.*) {
            .box => |*box| box.draw(),
            .text => |*text| text.draw(),
        }
        if (self.isSelected()) {
            rl.drawRectangleLinesEx(self.hitBoxPad(4, 4), 4, .blue);
        }
    }

    pub fn hitBox(self: *const Entity) rl.Rectangle {
        return switch (self.*) {
            .box => |*box| box.hitBox(),
            .text => |*text| text.hitBox(),
        };
    }

    pub fn hitBoxPad(self: *const Entity, x_pad: f32, y_pad: f32) rl.Rectangle {
        return rectPad(self.hitBox(), x_pad, y_pad);
    }
};

pub const Box = struct {
    x: i32,
    y: i32,
    width: i32,
    height: i32,
    color: rl.Color,
    is_selected: bool = false,

    pub fn draw(self: *const Box) void {
        rl.drawRectangle(self.x, self.y, self.width, self.height, self.color);
    }

    pub fn hitBox(self: *const Box) rl.Rectangle {
        return rectFromi32(self.x, self.y, self.width, self.height);
    }
};

pub const Text = struct {
    x: i32,
    y: i32,
    font_size: i32,
    color: rl.Color,
    text: [:0]const u8,
    is_selected: bool = false,

    pub fn draw(self: *const Text) void {
        rl.drawText(self.text, self.x, self.y, self.font_size, self.color);
    }

    pub fn hitBox(self: *const Text) rl.Rectangle {
        const width = rl.measureText(self.text, self.font_size);
        return rectFromi32(self.x, self.y, width, self.font_size);
    }
};

fn rectFromi32(x: i32, y: i32, width: i32, height: i32) rl.Rectangle {
    return .init(@floatFromInt(x), @floatFromInt(y), @floatFromInt(width), @floatFromInt(height));
}

fn rectPad(rec: rl.Rectangle, x_pad: f32, y_pad: f32) rl.Rectangle {
    return .init(rec.x - x_pad, rec.y - y_pad, rec.width + x_pad * 2, rec.height + y_pad * 2);
}
