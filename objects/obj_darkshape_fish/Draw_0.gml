/// one piece: its animation normally, or its shrivel frames + white glow + shudder while it's being purified
var _draw = function(_anim, _shrink, _p, _l, _i, _k)
{
    var _spr = (_l > 0) ? _shrink : _anim;
    var _img = (_l > 0) ? min(5, floor(_l * 6)) : floor(t * 0.125 + _i * 0.7) mod sprite_get_number(_anim);
    var _dx  = round(_p.x + ((_l > 0) ? random_range(-1, 1) * _l : 0)), _dy = round(_p.y);
    draw_sprite_ext(_spr, _img, _dx, _dy, _k, _k, _p.a, c_white, image_alpha);
    if (_l > 0)
    {
        gpu_set_fog(true, c_white, 0, 0);
        draw_sprite_ext(_spr, _img, _dx, _dy, _k, _k, _p.a, c_white, image_alpha * _l);
        gpu_set_fog(false, c_white, 0, 0);
    }
}

// body back to front (orbs draw themselves), then the head on top
for (var i = array_length(segs) - 1; i >= 0; i--)
{
    if (i + 1 >= array_length(parts) || instance_exists(segs[i].orb)) continue;
    var _tail = (i == array_length(segs) - 1);
    _draw(_tail ? spr_darkshape_directed_tail_animated : spr_darkshape_directed_animated,
          _tail ? spr_darkshape_directed_tail : spr_darkshape_directed, parts[i + 1], segs[i].light, i, art_scale * grow);
}
_draw(spr_darkshape_directed_head_animated, spr_darkshape_directed_head, parts[0], light, -1, art_scale * grow * pop);