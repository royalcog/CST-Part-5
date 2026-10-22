var _no_box = !(instance_exists(obj_battlebox) && obj_battlebox.visible);

// --- the whole screen as the light blue grid (only while the box is gone) ---
if (grid_fade > 0.01 && _no_box)
{
    var _cam = view_camera[0];
    var _vx = camera_get_view_x(_cam), _vy = camera_get_view_y(_cam);

    // darken everything behind it so the grid and warnings are easy to read
    draw_set_color(c_black);
    draw_set_alpha(grid_fade * dim_alpha_max);
    draw_rectangle(_vx - 50, _vy - 50, _vx + camera_get_view_width(_cam) + 50, _vy + camera_get_view_height(_cam) + 50, false);

    var _b  = scr_get_attack_bounds();
    var _cw = (_b.x2 - _b.x1) / 3, _ch = (_b.y2 - _b.y1) / 3;

    // sectors about to be cut fill up red
    for (var i = 0; i < array_length(slashes); i++)
    {
        var _sl = slashes[i];
        if (_sl.state != "warn" || array_length(_sl.cells) == 0) continue;
        var _k = clamp(_sl.t / _sl.charge, 0, 1);
        var _blink = (_sl.charge - _sl.t <= warn_blink) && ((_sl.t div 3) mod 2 == 0);
        draw_set_color(warn_color);
        draw_set_alpha(grid_fade * (_blink ? cell_alpha_max : cell_alpha_max * (0.25 + 0.6 * _k)));
        for (var c = 0; c < 3; c++)
        {
            var _cx = _b.x1 + _sl.cells[c][0] * _cw, _cy = _b.y1 + _sl.cells[c][1] * _ch;
            draw_rectangle(_cx + 2, _cy + 2, _cx + _cw - 2, _cy + _ch - 2, false);
        }
    }

    var _glow = 0;
    with (obj_soul) if (soul_mode == "lightblue") _glow = grid_alpha;
    draw_set_color(blue_color);
    draw_set_alpha(grid_fade * min(grid_alpha_base + _glow, 1));
    for (var i = 1; i <= 2; i++)
    {
        var _gx = lerp(_b.x1, _b.x2, i / 3);
        var _gy = lerp(_b.y1, _b.y2, i / 3);
        draw_line_width(_gx, _b.y1, _gx, _b.y2, grid_line_w);
        draw_line_width(_b.x1, _gy, _b.x2, _gy, grid_line_w);
    }
    draw_rectangle(_b.x1, _b.y1, _b.x2, _b.y2, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// --- slashes ---
for (var i = 0; i < array_length(slashes); i++)
{
    var _sl = slashes[i];
    if (_sl.state == "warn")
    {
        // thin warning line, brighter as it charges, blinking right before the cut
        var _k = clamp(_sl.t / _sl.charge, 0, 1);
        var _blink = (_sl.charge - _sl.t <= warn_blink) && ((_sl.t div 3) mod 2 == 0);
        draw_set_color(_blink ? c_white : warn_color);
        draw_set_alpha(0.3 + 0.6 * _k);
        draw_line_width(_sl.x1, _sl.y1, _sl.x2, _sl.y2, 1 + _k);
    }
    else
    {
        // the cut: a bright line that thins out
        var _k = _sl.t / cut_frames;
        var _w = cut_width * (1 - _k);
        gpu_set_blendmode(bm_add);
        draw_set_color(warn_color);
        draw_set_alpha(0.6 * (1 - _k));
        draw_line_width(_sl.x1, _sl.y1, _sl.x2, _sl.y2, _w + 6);
        gpu_set_blendmode(bm_normal);
        draw_set_color(c_white);
        draw_set_alpha(1 - _k);
        draw_line_width(_sl.x1, _sl.y1, _sl.x2, _sl.y2, max(_w, 1));
    }
}
draw_set_alpha(1);
draw_set_color(c_white);

// --- burst when the soul changes colour ---
if (flash_t > 0)
{
    var _k = 1 - flash_t / flash_frames;
    gpu_set_blendmode(bm_add);
    draw_set_color(flash_col);
    draw_set_alpha((1 - _k) * 0.8);
    draw_circle(flash_x, flash_y, flash_radius * _k, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}