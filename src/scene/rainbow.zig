const argh = @import("argh");

const rainbow_colors = [_]argh.Color{
    argh.red,
    argh.orange,
    argh.yellow,
    argh.green,
    argh.blue,
    argh.violet,
    argh.magenta,
};

const snake_seq_top_bottom = [_]argh.S{
    .sonic(argh.V.big.m2(argh.V.screen_x_big_fit_times - 1, 0)),
    .sonic(argh.V.big.m2(argh.V.screen_x_big_fit_times - 1, 1)),
    .sonic(argh.V.big.m2(0, 1)),
    .sonic(argh.V.big.m2(0, 2)),
    .sonic(argh.V.big.m2(argh.V.screen_x_big_fit_times - 1, 2)),
    .sonic(argh.V.big.m2(argh.V.screen_x_big_fit_times - 1, 3)),
    .sonic(argh.V.big.m2(0, 3)),
    .sonic(argh.V.big.m2(0, 4)),
    .sonic(argh.V.big.m2(argh.V.screen_x_big_fit_times - 1, 4)),
    .sonic(argh.V.big.m2(argh.V.screen_x_big_fit_times - 1, 5)),
};

const snake_seq_bottom_top = [_]argh.S{
    .sonic(argh.V.screen.m2(0, -1)),
};

const snake_seq_left_right = [_]argh.S{
    .sonic(argh.V.screen.m2(1, 0)),
};

pub fn snake() type {
    return struct {
        const Snake = @This();

        const AnimationType = enum {
            topBottom,
            bottomTop,
            leftRight,
        };

        body: [rainbow_colors.len]argh.O = undefined,
        anim: AnimationType = undefined,

        pub fn create() Snake {
            var snk = Snake{};
            snk.setAnimation(.topBottom);
            return snk;
        }

        fn setAnimation(snk: *Snake, anim: AnimationType) void {
            snk.anim = anim;
            switch (anim) {
                .topBottom => {
                    const sz = argh.V.big;
                    for (rainbow_colors, 0.., 1..) |color, i, n| {
                        const f: f32 = @floatFromInt(n);
                        snk.body[i] = argh.O.object(.still(sz.m1(-f)), sz, color);
                    }
                    for (&snk.body) |*o| o.setSequence(snake_seq_top_bottom[0..]);
                },
                .bottomTop => {
                    for (rainbow_colors, 0..) |color, i| {
                        const f: f32 = @floatFromInt(i);
                        snk.body[i] = argh.O.object(
                            .still(argh.V.screen.m2(0, f + 1)),
                            argh.V.screen,
                            color,
                        );
                    }
                    for (&snk.body) |*o| o.setSequence(snake_seq_bottom_top[0..]);
                },
                .leftRight => {
                    for (rainbow_colors, 0..) |color, i| {
                        const f: f32 = @floatFromInt(i);
                        snk.body[i] = argh.O.object(
                            .still(argh.V.screen.m2(-(f + 1), 0)),
                            argh.V.screen,
                            color,
                        );
                    }
                    for (&snk.body) |*o| o.setSequence(snake_seq_left_right[0..]);
                },
            }
        }

        pub fn update(snk: *Snake) void {
            for (&snk.body) |*o| o.update();
            if (snk.isSequenceComplete()) {
                switch (snk.anim) {
                    .topBottom => snk.setAnimation(.bottomTop),
                    .bottomTop => snk.setAnimation(.leftRight),
                    .leftRight => snk.setAnimation(.topBottom),
                }
            }
        }

        pub fn isSequenceComplete(snk: *const Snake) bool {
            for (snk.body) |o| {
                if (!o.isSequenceComplete()) return false;
            }
            return true;
        }

        pub fn draw(snk: *const Snake) void {
            for (&snk.body) |*o| o.draw();
        }
    };
}
