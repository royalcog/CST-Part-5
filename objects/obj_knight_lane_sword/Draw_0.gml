var _spr = spr_roaringknight_sword;
var _a   = dir + tip_angle_offset;

if (state == "charge")
{
    var _k = clamp(t / charge, 0, 1);
    draw_sprite_ext(_spr, 0, x, y, sword_scale, sword_scale, _a, c_white, alpha);
    gpu_set_fog(true, c_red, 0, 1);
    draw_sprite_ext(_spr, 0, x, y, sword_scale, sword_scale, _a, c_white, alpha * _k);
    gpu_set_fog(false, c_black, 0, 0);
}
else if (state == "fly")
{
    gpu_set_fog(true, c_red, 0, 1);
    var _n = array_length(trail);
    for (var j = _n - 1; j >= 0; j--)
    {
        draw_sprite_ext(_spr, 0, trail[j].x, trail[j].y, sword_scale, sword_scale, _a, c_white, flight_alpha * (1 - (j + 1) / (_n + 1)));
    }
    draw_sprite_ext(_spr, 0, x, y, sword_scale, sword_scale, _a, c_white, flight_alpha);
    gpu_set_fog(false, c_black, 0, 0);
}
else if (state == "shatter")
{
    // breaks apart against the barrier
    var _k = shatter_t / shatter_frames;
    gpu_set_blendmode(bm_add);
    draw_set_color(shatter_color);
    draw_set_alpha(1 - _k);
    for (var i = 0; i < 6; i++)
    {
        var _d = dir + 180 + (i - 2.5) * 22;
        var _r = 6 + 22 * _k;
        draw_line_width(shatter_x, shatter_y, shatter_x + lengthdir_x(_r, _d), shatter_y + lengthdir_y(_r, _d), 2);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}