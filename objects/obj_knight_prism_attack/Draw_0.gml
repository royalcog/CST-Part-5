var _c = scr_box_center();

// --- light blue: red fill on the sectors about to be cut ---
scr_slash_cells_draw(scr_get_attack_bounds());

// --- swords ---
for (var i = 0; i < array_length(swords); i++)
{
    var _w = swords[i];
    if (_w.alpha <= 0) continue;
    var _tip = sword_tip(_w, _c);
    var _x = _tip.x + lengthdir_x(tip_off, _w.ang), _y = _tip.y + lengthdir_y(tip_off, _w.ang);
    draw_sprite_ext(spr_roaringknight_sword, 0, _x, _y, sword_scale, sword_scale, _w.ang + 180, c_white, _w.alpha);
}

// --- cuts ---
scr_slashes_draw();

// --- blocks ---
gpu_set_blendmode(bm_add);
for (var i = 0; i < array_length(sparks); i++)
{
    var _sp = sparks[i];
    var _k = _sp.t / spark_frames;
    draw_set_color(col_green);
    draw_set_alpha(1 - _k);
    for (var j = -2; j <= 2; j++)
    {
        var _d = _sp.ang + j * 30;
        var _r = 4 + 14 * _k;
        draw_line_width(_sp.x, _sp.y, _sp.x + lengthdir_x(_r, _d), _sp.y + lengthdir_y(_r, _d), 2);
    }
}

// --- the next colour closing in on the soul ---
var _s = get_soul();
if (swapping && instance_exists(_s))
{
    var _left = swap_est - swap_el;            // about how long until it lands
    var _k = clamp(_left / swap_est, 0, 1);    // 1 -> 0 (holds small if the cast runs long)
    var _blink = (_left < 10) && ((swap_el div 2) mod 2 == 0);
    draw_set_color(_blink ? c_white : mode_color(next_mode));
    draw_set_alpha(0.4 + 0.6 * (1 - _k));
    draw_circle(_s.x, _s.y, 8 + swap_ring_r * _k, true);
    draw_circle(_s.x, _s.y, 7 + swap_ring_r * _k, true);
}

// --- the Knight's slash across the soul when he turns it red ---
if (mark_t > 0)
{
    var _k  = 1 - mark_t / knight_mark_frames; // 0 -> 1
    var _hl = knight_mark_len / 2 * (0.6 + 0.4 * _k);
    var _x1 = mark_x - lengthdir_x(_hl, mark_ang), _y1 = mark_y - lengthdir_y(_hl, mark_ang);
    var _x2 = mark_x + lengthdir_x(_hl, mark_ang), _y2 = mark_y + lengthdir_y(_hl, mark_ang);
    draw_set_color(col_red);
    draw_set_alpha(0.7 * (1 - _k));
    draw_line_width(_x1, _y1, _x2, _y2, 10 * (1 - _k) + 2);
    draw_set_color(c_white);
    draw_set_alpha(1 - _k);
    draw_line_width(_x1, _y1, _x2, _y2, max(4 * (1 - _k), 1));
}

// --- burst when it changes ---
if (flash_t > 0)
{
    var _k = 1 - flash_t / flash_frames;
    draw_set_color(flash_col);
    draw_set_alpha((1 - _k) * 0.8);
    draw_circle(flash_x, flash_y, flash_radius * _k, false);
}
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);