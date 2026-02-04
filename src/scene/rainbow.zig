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

const snake_seq_from_top_to_bottom = [_]argh.S{
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

const snake_seq_from_bottom_to_top = [_]argh.S{
    .sonic(argh.V.screen.m2(0, -1)),
};

pub fn snake() type {
    return struct {
        const Snake = @This();

        body: [rainbow_colors.len]argh.O = undefined,

        pub fn create() Snake {
            var snk = Snake{};
            const sz = argh.V.big;
            for (rainbow_colors, 0.., 1..) |color, i, n| {
                const f: f32 = @floatFromInt(n);
                snk.body[i] = argh.O.object(.still(sz.m1(-f)), sz, color);
            }
            for (&snk.body) |*o| o.setSequence(snake_seq_from_top_to_bottom[0..]);
            return snk;
        }

        pub fn update(snk: *Snake) void {
            for (&snk.body) |*o| o.update();
            if (snk.areAllComplete()) {
                for (rainbow_colors, 0..) |color, i| {
                    const f: f32 = @floatFromInt(i);
                    snk.body[i] = argh.O.object(
                        .still(argh.V.screen.m2(0, f + 1)),
                        argh.V.screen,
                        color,
                    );
                }
                for (&snk.body) |*o| o.setSequence(snake_seq_from_bottom_to_top[0..]);
            }
        }

        pub fn areAllComplete(snk: *const Snake) bool {
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
