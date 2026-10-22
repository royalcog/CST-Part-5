// the Titan's tower as it stands after Part 4 (stone all the way up, no geyser, no hand in this shot).
// lives on the "Titan" layer (345): behind the floor tiles (300), in front of the background (400)
if (instance_exists(obj_shadow_tint)) array_push(obj_shadow_tint.skip_layers, layer_get_name(layer));
if (instance_exists(obj_dark_fountain)) obj_dark_fountain.visible = false;

// --- same numbers obj_titan_spawn uses, so it lines up with Part 4's wide shot ---
fx            = room_width / 2;
pillar_w      = 274;
tower_scale   = pillar_w / sprite_get_width(spr_titantower_piece);
base_bottom_y = 384;     // room y of the pool's bottom edge (the platform edge is 364)
tower_shade   = 0.85;    // the tower darkens toward its base...
tower_shade_h = 200;     // ...over this many px
parallax      = 1;       // 1 = moves with the room (rm_two). smaller = scrolls slower, so it feels further back

/// tiles _spr upward from _anchor (its bottom edge), only drawing what's between _top and _bottom
draw_column = function(_spr, _img, _anchor, _top, _bottom, _sc)
{
    if (_bottom <= _top) return;
    var _w    = sprite_get_width(_spr);
    var _th   = sprite_get_height(_spr) * _sc;
    var _left = fx - sprite_get_xoffset(_spr) * _sc;
    var _k    = max(0, floor((_anchor - _bottom) / _th));

    for (var _tb = _anchor - _k * _th; _tb > _top; _tb -= _th)
    {
        var _tt = _tb - _th;
        var _vt = max(_tt, _top);
        var _vb = min(_tb, _bottom);
        if (_vb <= _vt) continue;
        draw_sprite_part_ext(_spr, _img, 0, (_vt - _tt) / _sc, _w, (_vb - _vt) / _sc, _left, _vt, _sc, _sc, c_white, 1);
    }
}