var _c = scr_box_center();

// --- swords (point at the soul) ---
for (var i = 0; i < array_length(swords); i++)
{
    var _w = swords[i];
    // dist is where the tip is, so the sprite's middle sits tip_off further out
    var _x = _c.x + lengthdir_x(_w.dist + tip_off, _w.ang), _y = _c.y + lengthdir_y(_w.dist + tip_off, _w.ang);
    var _a = min(_w.t / fade_in, 1);
    if (_w.feint) gpu_set_fog(true, feint_color, 0, 1);
    draw_sprite_ext(spr_roaringknight_sword, 0, _x, _y, sword_scale, sword_scale, _w.ang + 180, c_white, _a);
    if (_w.feint) gpu_set_fog(false, c_black, 0, 0);
}

// --- blocks ---
gpu_set_blendmode(bm_add);
for (var i = 0; i < array_length(sparks); i++)
{
    var _s = sparks[i];
    var _k = _s.t / spark_frames;
    draw_set_color(green_color);
    draw_set_alpha(1 - _k);
    for (var j = -2; j <= 2; j++)
    {
        var _d = _s.ang + j * 30;
        var _r = 4 + 14 * _k;
        draw_line_width(_s.x, _s.y, _s.x + lengthdir_x(_r, _d), _s.y + lengthdir_y(_r, _d), 2);
    }
}

// --- burst when the soul turns green ---
if (flash_t > 0)
{
    var _k = 1 - flash_t / flash_frames;
    draw_set_color(green_color);
    draw_set_alpha((1 - _k) * 0.8);
    draw_circle(flash_x, flash_y, flash_radius * _k, false);
}
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);