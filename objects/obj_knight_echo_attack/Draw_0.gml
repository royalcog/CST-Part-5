var _s = get_soul();
var _col = scr_soul_swap_color(instance_exists(_s) ? _s.soul_mode : "red");

// --- light blue: red fill on the sectors about to be cut ---
scr_slash_cells_draw(scr_get_attack_bounds());

// --- echoes, with a faint preview of where each one goes next (the path you already took) ---
for (var i = 0; i < array_length(echoes); i++)
{
    var _e = echoes[i];
    if (_e.t <= 0 && !_e.dying) continue;
    for (var k = echo_trail; k >= 1; k--)
    {
        var _p = history_at(_e.delay - k * echo_trail_step);
        if (is_undefined(_p) || _e.delay - k * echo_trail_step < 0) continue;
        draw_echo(_p.x, _p.y, _e.alpha * 0.25 * (1 - k / (echo_trail + 1)), _col);
    }
    draw_echo(_e.x, _e.y, _e.alpha, _col);
}

// --- green finale echoes ---
for (var i = 0; i < array_length(finale); i++)
{
    var _f = finale[i];
    var _fc = sw_col_green;
    // the next one to go blinks white
    if (_f.state == "wait" && state == "finale" && timer < 12 && (timer div 3) mod 2 == 0)
    {
        var _first = true;
        for (var j = 0; j < i; j++) if (finale[j].state == "wait") _first = false;
        if (_first) _fc = c_white;
    }
    draw_echo(_f.x, _f.y, _f.alpha, _fc);
}

// --- cuts ---
scr_slashes_draw();

// --- blocks ---
gpu_set_blendmode(bm_add);
for (var i = 0; i < array_length(sparks); i++)
{
    var _sp = sparks[i];
    var _k = _sp.t / spark_frames;
    draw_set_color(sw_col_green);
    draw_set_alpha(1 - _k);
    for (var j = -2; j <= 2; j++)
    {
        var _d = _sp.ang + j * 30;
        var _r = 4 + 14 * _k;
        draw_line_width(_sp.x, _sp.y, _sp.x + lengthdir_x(_r, _d), _sp.y + lengthdir_y(_r, _d), 2);
    }
}
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);

// --- colour changes ---
scr_soul_swap_draw();