if (!instance_exists(obj_battlebox)) exit;

var _in  = scr_get_box_interior(); // box's own (unrotated) frame
var _spr = sprite_index;
var _w   = sprite_get_width(_spr);
var _h   = sprite_get_height(_spr);
var _ox  = sprite_get_xoffset(_spr);
var _oy  = sprite_get_yoffset(_spr);
var _sx  = image_xscale;
var _sy  = image_yscale;
var _dx  = round(lx);
var _dy  = round(ly);

// which sprite columns/rows land inside the box interior (works flipped too)
var _ua = _ox + (_in.x1 - _dx) / _sx;
var _ub = _ox + (_in.x2 - _dx) / _sx;
var _u0 = clamp(ceil(min(_ua, _ub)), 0, _w);
var _u1 = clamp(floor(max(_ua, _ub)), 0, _w);
var _v0 = clamp(ceil(_oy + (_in.y1 - _dy) / _sy), 0, _h);
var _v1 = clamp(floor(_oy + (_in.y2 - _dy) / _sy), 0, _h);

if (_u1 <= _u0 || _v1 <= _v0) exit;

// top-left corner of the visible part, in the box's frame -> world (rotated with the box)
var _corner = scr_box_local_to_world(_dx + (_u0 - _ox) * _sx, _dy + (_v0 - _oy) * _sy);

draw_sprite_general(_spr, image_index, _u0, _v0, _u1 - _u0, _v1 - _v0,
    _corner.x, _corner.y, _sx, _sy, obj_battlebox.box_angle,
    image_blend, image_blend, image_blend, image_blend, image_alpha);