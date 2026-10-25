if (phase == "wait") exit;
var _dx = scr_plat_draw_x(bx);
var _t  = camera_get_view_y(view_camera[0]) - 10;
var _b  = _t + camera_get_view_height(view_camera[0]) + 20;

if (phase == "aim")
{
    // the thin flickering line
    draw_set_alpha(0.35 + 0.35 * ((pt div 3) mod 2));
    draw_set_colour(c_white);
    draw_rectangle(_dx - 1, _t, _dx + 1, _b, false);
}
else
{
    // the beam: a soft glow around a bright middle, thinning as it fades
    var _k = (phase == "fire") ? 1 : 1 - pt / fade_len;
    var _w = width * (phase == "fire" ? (1 + 0.08 * sin(pt * 0.8)) : _k);
    gpu_set_blendmode(bm_add);
    draw_set_colour(c_white);
    draw_set_alpha(0.35 * _k);
    draw_rectangle(_dx - _w / 2 - 8, _t, _dx + _w / 2 + 8, _b, false);
    draw_set_alpha(0.9 * _k);
    draw_rectangle(_dx - _w / 2, _t, _dx + _w / 2, _b, false);
    gpu_set_blendmode(bm_normal);
}
draw_set_alpha(1);
draw_set_colour(c_white);