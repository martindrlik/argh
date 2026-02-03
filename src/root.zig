const std = @import("std");

const c = @cImport({
    @cInclude("raylib.h");
});

pub const S = @import("State.zig");
pub const O = @import("Object.zig");
pub const V = @import("Vec.zig");

pub const Camera2D = c.Camera2D;
pub const Color = c.Color;
pub const Font = c.Font;
pub const Rectangle = c.Rectangle;
pub const RenderTexture2D = c.RenderTexture2D;
pub const Shader = c.Shader;
pub const ShaderUniformFloat = c.SHADER_UNIFORM_FLOAT;
pub const ShaderUniformVec2 = c.SHADER_UNIFORM_VEC2;
pub const Vector2 = c.Vector2;
pub const beginDrawing = c.BeginDrawing;
pub const beginMode2D = c.BeginMode2D;
pub const beginShaderMode = c.BeginShaderMode;
pub const beginTextureMode = c.BeginTextureMode;
pub const black = c.BLACK;
pub const blue = c.BLUE;
pub const checkCollisionRecs = c.CheckCollisionRecs;
pub const clearBackground = c.ClearBackground;
pub const closeWindow = c.CloseWindow;
pub const drawFps = c.DrawFPS;
pub const drawRectangleLinesEx = c.DrawRectangleLinesEx;
pub const drawRectangleRec = c.DrawRectangleRec;
pub const drawText = c.DrawText;
pub const drawTextEx = c.DrawTextEx;
pub const drawTexture = c.DrawTexture;
pub const drawTexturePro = c.DrawTexturePro;
pub const drawTextureRec = c.DrawTextureRec;
pub const endDrawing = c.EndDrawing;
pub const endMode2D = c.EndMode2D;
pub const endShaderMode = c.EndShaderMode;
pub const endTextureMode = c.EndTextureMode;
pub const formatText = c.TextFormat;
pub const getCharPressed = c.GetCharPressed;
pub const getShaderLocation = c.GetShaderLocation;
pub const getTime = c.GetTime;
pub const gray = c.GRAY;
pub const green = c.GREEN;
pub const initWindow = c.InitWindow;
pub const isKeyDown = c.IsKeyDown;
pub const isKeyPressed = c.IsKeyPressed;
pub const key_a = c.KEY_A;
pub const key_backspace = c.KEY_BACKSPACE;
pub const key_d = c.KEY_D;
pub const key_p = c.KEY_P;
pub const key_s = c.KEY_S;
pub const key_space = c.KEY_SPACE;
pub const key_w = c.KEY_W;
pub const loadFontEx = c.LoadFontEx;
pub const loadRenderTexture = c.LoadRenderTexture;
pub const loadShader = c.LoadShader;
pub const loadTexture = c.LoadTexture;
pub const raywhite = c.RAYWHITE;
pub const red = c.RED;
pub const setShaderValue = c.SetShaderValue;
pub const setTargetFps = c.SetTargetFPS;
pub const unloadShader = c.UnloadShader;
pub const unloadTexture = c.UnloadTexture;
pub const wait = c.WaitTime;
pub const white = c.WHITE;
pub const windowShouldClose = c.WindowShouldClose;

test {
    std.testing.refAllDecls(@This());
}
