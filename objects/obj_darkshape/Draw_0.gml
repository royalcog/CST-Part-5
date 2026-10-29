// Deltarune's: while it's appearing, each row of the sprite sways side to side and settles as it fades in.
// it goes white as it's purified (its shrivel frames + white over the top)
var _k   = art_scale * scalefactor * grow;
var _ang = face_dir ? dir : 0;
var _shr = (light > 0 && shrink_sprite != -1);
var _spr = _shr ? shrink_sprite : anim_sprite;
var _img = _shr ? stage : floor(anim_f) mod sprite_get_number(anim_sprite);
var _wob = 4 - image_alpha * 4;   // DR: 4px of sway when it first appears, none once it's in

if (_wob > 0.05 && _ang == 0)
{
    var _w  = sprite_get_width(_spr), _h = sprite_get_height(_spr);
    var _ox = sprite_get_xoffset(_spr), _oy = sprite_get_yoffset(_spr);
    for (var r = 0; r < _h; r++)
        draw_sprite_part_ext(_spr, _img, 0, r, _w, 1,
            round(x - _ox * _k + sin(r + t * 0.5) * _wob), round(y + (r - _oy) * _k), _k, _k, c_white, image_alpha);
}
else draw_sprite_ext(_spr, _img, round(x), round(y), _k, _k, _ang, c_white, image_alpha);

if (light > 0)
{
    gpu_set_fog(true, c_white, 0, 0);
    draw_sprite_ext(_spr, _img, round(x) + 1, round(y), _k, _k, _ang, c_white, light);
    gpu_set_fog(false, c_white, 0, 0);
}