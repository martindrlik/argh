const debug = @import("debug.zig");
const Enemy = @import("Enemy.zig");
const Engine = @import("Engine.zig");
const physics_step_seconds = Engine.physics_step_seconds;
const Input = @import("Input.zig");
const Player = @import("Player.zig");
const Position = @import("Position.zig");
const Vector = Position.Vector;

pub const Entity = union(enum) {
    enemy: Enemy,
    player: Player,

    pub fn physicsStep(self: *Entity, input: *Input) void {
        switch (self.*) {
            .enemy => |*enemy| enemy.physicsStep(),
            .player => |*player| player.physicsStep(input),
        }
    }

    pub fn draw(self: *const Entity, alpha: f64) void {
        switch (self.*) {
            .enemy => |*enemy| debug.printEnemy(enemy, alpha),
            .player => |*player| debug.printPlayer(player, alpha),
        }
    }
};
