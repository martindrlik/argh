const argh = @import("argh");
const S = argh.S;
const V = argh.V;

const rainbow_colors = [_]argh.Color{
    argh.red,
    argh.orange,
    argh.yellow,
    argh.green,
    argh.blue,
    argh.violet,
    argh.magenta,
};

const snake_seq_top_bottom = [_]S{
    S.init(V.big.mul(.vec(V.big_fit_times.x - 1, 0))).sonic(),
    S.init(V.big.mul(.vec(V.big_fit_times.x - 1, 1))).sonic(),
    S.init(V.big.mul(.vec(0, 1))).sonic(),
    S.init(V.big.mul(.vec(0, 2))).sonic(),
    S.init(V.big.mul(.vec(V.big_fit_times.x - 1, 2))).sonic(),
    S.init(V.big.mul(.vec(V.big_fit_times.x - 1, 3))).sonic(),
    S.init(V.big.mul(.vec(0, 3))).sonic(),
    S.init(V.big.mul(.vec(0, 4))).sonic(),
    S.init(V.big.mul(.vec(V.big_fit_times.x - 1, 4))).sonic(),
    S.init(V.big.mul(.vec(V.big_fit_times.x - 1, 5))).sonic(),
};

const snake_seq_bottom_top = [_]S{
    S.init(V.screen.mul(.vec(0, 1))).screen().sonic(),
    S.init(V.screen.mul(.vec(0, -1))).small().sonic(),
};

const snake_seq_left_right = [_]S{
    S.init(V.screen.mul(.vec(1, 0))).screen().sonic(),
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
                    const big = argh.V.big;
                    for (rainbow_colors, 0.., 1..) |color, i, n| {
                        const f: f32 = @floatFromInt(n);
                        snk.body[i] = argh.O.object(.init(big.mul(.constant(-f))), color);
                    }
                    for (&snk.body) |*o| o.setSequence(snake_seq_top_bottom[0..]);
                },
                .bottomTop => {
                    for (rainbow_colors, 0..) |color, i| {
                        const f: f32 = @floatFromInt(i);
                        snk.body[i] = argh.O.object(
                            S.init(V.screen.mul(.vec(0, f + 1))).screen(),
                            color,
                        );
                    }
                    for (&snk.body) |*o| o.setSequence(snake_seq_bottom_top[0..]);
                },
                .leftRight => {
                    for (rainbow_colors, 0..) |color, i| {
                        const f: f32 = @floatFromInt(i);
                        snk.body[i] = argh.O.object(
                            S.init(V.screen.mul(.vec(-(f + 1), 0))).screen(),
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
