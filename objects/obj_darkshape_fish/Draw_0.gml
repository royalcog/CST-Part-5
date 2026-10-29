// tail first, head on top. while it's being purified the whole fish shrivels, shudders and glows white
var _n = array_length(parts);
var _stage = min(5, floor(light * 6));
for (var i = _n - 1; i >= 0; i--)
{
    var _p    = parts[i];
    var _head = (i == 0);
    var _tail = (i == _n - 1 && i > 0 && _n == pieces + 1);
    var _spr, _img;
    if (light > 0)
    {
        _spr = _head ? spr_darkshape_directed_head : (_tail ? spr_darkshape_directed_tail : spr_darkshape_directed);
        _img = _stage;
    }
    else
    {
        _spr = _head ? spr_darkshape_directed_head_animated : (_tail ? spr_darkshape_directed_tail_animated : spr_darkshape_directed_animated);
        _img = floor(t * 0.125 + i * 0.7) mod sprite_get_number(_spr);
    }
    var _dx = round(_p.x + ((light > 0) ? random_range(-1, 1) * light : 0)), _dy = round(_p.y);
    draw_sprite_ext(_spr, _img, _dx, _dy, art_scale, art_scale, _p.a, c_white, image_alpha);
    if (light > 0)
    {
        gpu_set_fog(true, c_white, 0, 0);
        draw_sprite_ext(_spr, _img, _dx, _dy, art_scale, art_scale, _p.a, c_white, image_alpha * light * 0.7);
        gpu_set_fog(false, c_white, 0, 0);
    }
}