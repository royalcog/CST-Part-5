var _w = door_x2 - door_x1, _h = door_y2 - door_y1;

// grab the door's pixels off the tiles once
if (door_spr == -1)
{
    var _tm = layer_tilemap_get_id(layer_get_id("Tiles_1"));
    var _sf = surface_create(_w, _h);
    surface_set_target(_sf);
    draw_clear_alpha(c_black, 0);
    draw_tilemap(_tm, -door_x1, -door_y1);
    surface_reset_target();
    door_spr = sprite_create_from_surface(_sf, 0, 0, _w, _h, false, false, 0, 0);
    surface_free(_sf);
}

// the doorway
if (state == "broken")
{
    draw_set_alpha(1);
    draw_set_color(open_color);
    draw_roundrect_ext(door_x1 + 1, door_y1 + 1, door_x2 - 1, door_y2, open_radius, open_radius, false);
}
// still standing on its cut for a few frames, shaking
else if (state == "cut" && sprite_exists(door_spr))
{
    draw_sprite(door_spr, 0, door_x1 + random_range(-1.5, 1.5), door_y1 + random_range(-1, 1));
}

// the shards
if (array_length(shards) > 0 && sprite_exists(door_spr))
{
    var _uv = sprite_get_uvs(door_spr, 0);
    var _uw = (_uv[2] - _uv[0]) / _w, _vh = (_uv[3] - _uv[1]) / _h;
    draw_primitive_begin_texture(pr_trianglelist, sprite_get_texture(door_spr, 0));
    for (var i = 0; i < array_length(shards); i++)
    {
        var _s  = shards[i];
        var _a  = (_s.t < shard_life - shard_fade) ? 1 : (shard_life - _s.t) / shard_fade;
        var _cs = dcos(_s.rot), _sn = dsin(_s.rot);
        for (var k = 0; k < 3; k++)
        {
            var _lx = _s.lx[k], _ly = _s.ly[k];
            draw_vertex_texture_colour(_s.x + _lx * _cs + _ly * _sn, _s.y - _lx * _sn + _ly * _cs,
                                       _uv[0] + _s.u[k] * _uw, _uv[1] + _s.v[k] * _vh, c_white, _a);
        }
    }
    draw_primitive_end();
}

// the cut line
if (state != "idle" && (state == "cut" || t < cut_frames - break_delay))
{
    var _k  = (state == "cut") ? t / cut_frames : (t + break_delay) / cut_frames;
    var _cw = cut_width * (1 - _k);
    gpu_set_blendmode(bm_add);
    draw_set_color(c_white);
    draw_set_alpha(0.35 * (1 - _k));
    draw_line_width(cut_x1, cut_y1, cut_x2, cut_y2, _cw * 2.2);
    draw_set_alpha(1 - _k * 0.5);
    draw_line_width(cut_x1, cut_y1, cut_x2, cut_y2, max(_cw, 1));
    gpu_set_blendmode(bm_normal);
}

// white flash when it's cut and again when it bursts
if (flash > 0)
{
    gpu_set_blendmode(bm_add);
    draw_set_color(c_white);
    draw_set_alpha(flash * 0.6);
    draw_roundrect_ext(door_x1, door_y1, door_x2, door_y2, open_radius, open_radius, false);
    gpu_set_blendmode(bm_normal);
}
draw_set_alpha(1);
draw_set_color(c_white);