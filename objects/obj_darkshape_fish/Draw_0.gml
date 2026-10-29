// tail first, head on top. the burning end shrivels (the 6-frame sprites) and shudders
var _n = array_length(parts);
for (var i = _n - 1; i >= 0; i--)
{
    var _p = parts[i];
    var _head = (i == 0);
    var _tail = (i == _n - 1 && i > 0);
    var _burning = (i == _n - 1 && burn > 0 && _n == pieces + 1);
    var _spr, _img;
    if (_burning)
    {
        _spr = _head ? spr_darkshape_directed_head : (_tail ? spr_darkshape_directed_tail : spr_darkshape_directed);
        _img = min(5, floor(burn * 6));
    }
    else
    {
        _spr = _head ? spr_darkshape_directed_head_animated : (_tail ? spr_darkshape_directed_tail_animated : spr_darkshape_directed_animated);
        _img = floor(t * 0.125 + i * 0.7) mod sprite_get_number(_spr);
    }
    var _sh = _burning ? random_range(-1, 1) * burn : 0;
    draw_sprite_ext(_spr, _img, round(_p.x + _sh), round(_p.y), art_scale, art_scale, _p.a, c_white, image_alpha);
}