/// where a sprite's feet are, from its origin (sprite px): the middle of the lowest few rows of pixels in its first
/// frame. measured once per sprite, then remembered
function scr_sprite_feet(_spr)
{
    if (!variable_global_exists("sprite_feet_cache")) global.sprite_feet_cache = {};
    var _key = string(_spr);
    if (variable_struct_exists(global.sprite_feet_cache, _key)) return global.sprite_feet_cache[$ _key];

    var _w = sprite_get_width(_spr), _h = sprite_get_height(_spr);
    var _s = surface_create(_w, _h);
    surface_set_target(_s);
    draw_clear_alpha(c_black, 0);
    draw_sprite(_spr, 0, sprite_get_xoffset(_spr), sprite_get_yoffset(_spr));
    surface_reset_target();
    var _b = buffer_create(_w * _h * 4, buffer_fixed, 1);
    buffer_get_surface(_b, _s, 0);
    surface_free(_s);

    // the lowest row with anything in it...
    var _bot = -1;
    for (var _y = _h - 1; _y >= 0 && _bot < 0; _y--)
        for (var _x = 0; _x < _w; _x++)
            if (buffer_peek(_b, (_y * _w + _x) * 4 + 3, buffer_u8) > 0) { _bot = _y; break; }
    // ...and the middle of what's in the bottom 4 rows (the feet)
    var _l = _w, _r = -1;
    if (_bot >= 0)
        for (var _y = max(0, _bot - 3); _y <= _bot; _y++)
            for (var _x = 0; _x < _w; _x++)
                if (buffer_peek(_b, (_y * _w + _x) * 4 + 3, buffer_u8) > 0) { _l = min(_l, _x); _r = max(_r, _x); }
    buffer_delete(_b);

    var _res = (_bot < 0) ? { x: 0, y: 0 }
             : { x: (_l + _r + 1) / 2 - sprite_get_xoffset(_spr), y: _bot + 1 - sprite_get_yoffset(_spr) };
    global.sprite_feet_cache[$ _key] = _res;
    return _res;
}

/// _o into _spr facing _xs (2 = the sprite's own way, -2 = flipped), frame 0, its feet exactly where they were
function scr_pose_keep_feet(_o, _spr, _xs)
{
    if (!instance_exists(_o)) return;
    with (_o)
    {
        var _f0 = scr_sprite_feet(sprite_index), _f1 = scr_sprite_feet(_spr);
        var _fx = x + _f0.x * image_xscale, _fy = y + _f0.y * image_yscale;
        image_xscale = _xs;
        sprite_index = _spr;
        last_sprite  = _spr;
        image_index  = 0;
        x = _fx - _f1.x * image_xscale;
        y = _fy - _f1.y * image_yscale;
    }
}