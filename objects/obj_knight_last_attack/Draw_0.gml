var _c = scr_box_center();

// --- the darkness once the box is gone ---
if (dim > 0)
{
    var _cam = view_camera[0];
    var _vx = camera_get_view_x(_cam), _vy = camera_get_view_y(_cam);
    draw_set_color(c_black);
    draw_set_alpha(dim * dim_alpha_max);
    draw_rectangle(_vx - 50, _vy - 50, _vx + camera_get_view_width(_cam) + 50, _vy + camera_get_view_height(_cam) + 50, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// --- the whole-screen light blue grid ---
if (grid_fade > 0.01)
{
    var _gb = scr_get_attack_bounds();
    var _glow = 0;
    with (obj_soul) if (soul_mode == "lightblue") _glow = grid_alpha;
    draw_set_color(sw_col_blue);
    draw_set_alpha(grid_fade * min(grid_alpha_base + _glow, 1));
    for (var i = 1; i <= 2; i++)
    {
        var _gx = lerp(_gb.x1, _gb.x2, i / 3);
        var _gy = lerp(_gb.y1, _gb.y2, i / 3);
        draw_line_width(_gx, _gb.y1, _gx, _gb.y2, grid_line_w);
        draw_line_width(_gb.x1, _gy, _gb.x2, _gy, grid_line_w);
    }
    draw_rectangle(_gb.x1, _gb.y1, _gb.x2, _gb.y2, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// --- the dark corners ---
for (var k = 0; k < 9; k++)
{
    if (!dark[k] || !instance_exists(obj_battlebox)) continue;
    var _a  = dark_t[k] / dark_fade;
    var _r  = cell_rect(k);
    var _p1 = scr_box_local_to_world(_r.x1, _r.y1), _p2 = scr_box_local_to_world(_r.x2, _r.y2);
    draw_set_color(dark_color);
    draw_set_alpha(0.9 * _a);
    draw_rectangle(_p1.x + 1, _p1.y + 1, _p2.x - 1, _p2.y - 1, false);
    // flickering edge
    draw_set_color(dark_edge);
    draw_set_alpha(_a * (0.5 + 0.3 * sin(current_time / 90 + k)));
    draw_rectangle(_p1.x + 2, _p1.y + 2, _p2.x - 2, _p2.y - 2, true);
}
draw_set_alpha(1);
draw_set_color(c_white);

// --- the X's cracks on the box ---
if (instance_exists(obj_battlebox))
{
    draw_set_color(c_white);
    draw_set_alpha(0.85);
    for (var i = 0; i < array_length(box_cracks); i++)
    {
        var _ck = box_cracks[i];
        draw_line_width(_ck.x1, _ck.y1, _ck.x2, _ck.y2, 2);
    }
    draw_set_alpha(1);
}

// --- shards from the dark corners ---
for (var i = 0; i < array_length(shards); i++)
{
    var _p = shards[i];
    draw_set_color(_p.col);
    draw_set_alpha(1 - _p.t / shard_life);
    draw_line_width(_p.x - lengthdir_x(_p.len, _p.rot), _p.y - lengthdir_y(_p.len, _p.rot),
                    _p.x + lengthdir_x(_p.len, _p.rot), _p.y + lengthdir_y(_p.len, _p.rot), 2);
}
draw_set_alpha(1);
draw_set_color(c_white);

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