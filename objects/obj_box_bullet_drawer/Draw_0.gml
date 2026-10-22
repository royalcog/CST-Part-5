if (!instance_exists(obj_battlebox)) exit;
if (instance_number(obj_spade_burst) == 0 && instance_number(obj_spade_shot) == 0) exit;

var _in  = scr_get_box_interior(); // box's own (unrotated) frame
var _ang = obj_battlebox.box_angle;
var _ox = floor(_in.x1);
var _oy = floor(_in.y1);
var _w  = max(1, ceil(_in.x2) - _ox);
var _h  = max(1, ceil(_in.y2) - _oy);

if (!surface_exists(surf) || surface_get_width(surf) != _w || surface_get_height(surf) != _h)
{
    if (surface_exists(surf)) surface_free(surf);
    surf = surface_create(_w, _h);
}

// draw every box bullet onto an interior-sized surface in the box's own frame,
// so anything outside the box gets cut off even while it's tilted
surface_set_target(surf);
draw_clear_alpha(c_black, 0);
with (obj_spade_burst)
{
    var _l = scr_world_to_box_local(x, y);
    draw_sprite_ext(sprite_index, image_index, round(_l.x) - _ox, round(_l.y) - _oy,
        image_xscale, image_yscale, image_angle - _ang, image_blend, image_alpha);
}
with (obj_spade_shot)
{
    var _l = scr_world_to_box_local(x, y);
    draw_sprite_ext(sprite_index, image_index, round(_l.x) - _ox, round(_l.y) - _oy,
        image_xscale, image_yscale, image_angle - _ang, image_blend, image_alpha);
}
surface_reset_target();

// put it back in the world, rotated with the box around its center (same trick obj_battlebox uses)
var _c   = scr_box_center();
var _off = scr_rotate_point(_ox - _c.x, _oy - _c.y, _ang);
draw_surface_ext(surf, _c.x + _off.x, _c.y + _off.y, 1, 1, _ang, c_white, 1);