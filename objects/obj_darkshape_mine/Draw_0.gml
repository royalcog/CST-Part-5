// its frames step through 5 stages as the fuse runs (0, 2, 4, 6, 8), flickering with the frame after each;
// it flushes red as it goes. wobbles in rows while it's appearing, like every darkshape
var _stage = (fuse > 0.8) ? 8 : (fuse > 0.6) ? 6 : (fuse > 0.4) ? 4 : (fuse > 0.2) ? 2 : 0;
var _img   = _stage + ((t div 4) mod 2);
var _col   = make_color_rgb(255, (1 - fuse) * 255, (1 - fuse) * 255);
var _k     = art_scale;
var _wob   = 3 - image_alpha * 3;   // DR's

if (_wob > 0.05)
{
    var _w  = sprite_get_width(spr_darkshape_mine), _h = sprite_get_height(spr_darkshape_mine);
    var _ox = sprite_get_xoffset(spr_darkshape_mine), _oy = sprite_get_yoffset(spr_darkshape_mine);
    for (var r = 0; r < _h; r++)
        draw_sprite_part_ext(spr_darkshape_mine, _img, 0, r, _w, 1,
            round(x - _ox * _k + sin(r + t * 0.5) * _wob), round(y + (r - _oy) * _k), _k, _k, _col, image_alpha);
}
else draw_sprite_ext(spr_darkshape_mine, _img, round(x), round(y), _k, _k, 0, _col, image_alpha);