if (!instance_exists(obj_battlebox)) exit;

var _b = scr_get_box_interior();

// --- shattered sectors ---
for (var i = 0; i < 9; i++)
{
    var _c = cells[i];
    if (!_c.broken) continue;
    var _r = cell_rect(i);

    draw_set_color(broken_fill);
    draw_set_alpha(0.95);
    draw_rectangle(_r.x1 + 1, _r.y1 + 1, _r.x2 - 1, _r.y2 - 1, false);

    var _w = _r.x2 - _r.x1, _h = _r.y2 - _r.y1;
    draw_set_color(crack_color);
    draw_set_alpha(crack_alpha);
    for (var k = 0; k < array_length(_c.cracks); k++)
    {
        var _p = _c.cracks[k];
        draw_line_width(_r.x1 + _p[0] * _w, _r.y1 + _p[1] * _h, _r.x1 + _p[2] * _w, _r.y1 + _p[3] * _h, 1);
        draw_line_width(_r.x1 + _p[2] * _w, _r.y1 + _p[3] * _h, _r.x1 + _p[4] * _w, _r.y1 + _p[5] * _h, 1);
    }
    draw_rectangle(_r.x1 + 2, _r.y1 + 2, _r.x2 - 2, _r.y2 - 2, true);

    // white flash as it breaks
    if (_c.t < break_flash)
    {
        draw_set_color(c_white);
        draw_set_alpha(1 - _c.t / break_flash);
        draw_rectangle(_r.x1 + 1, _r.y1 + 1, _r.x2 - 1, _r.y2 - 1, false);
    }
}

// --- light blue wash when Susie fixes it ---
if (restore_t > 0)
{
    gpu_set_blendmode(bm_add);
    draw_set_color(crack_color);
    draw_set_alpha(0.5 * restore_t / restore_frames);
    draw_rectangle(_b.x1, _b.y1, _b.x2, _b.y2, false);
    gpu_set_blendmode(bm_normal);
}

// --- shards ---
draw_set_color(crack_color);
for (var i = 0; i < array_length(shards); i++)
{
    var _p = shards[i];
    draw_set_alpha(_p.life / shard_life);
    draw_line_width(_p.x - lengthdir_x(_p.len, _p.rot), _p.y - lengthdir_y(_p.len, _p.rot),
                    _p.x + lengthdir_x(_p.len, _p.rot), _p.y + lengthdir_y(_p.len, _p.rot), 2);
}
draw_set_alpha(1);
draw_set_color(c_white);

// --- warnings + cuts ---
scr_slash_cells_draw(_b);
scr_slashes_draw();