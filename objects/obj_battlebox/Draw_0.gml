if (split_axis != "none")
{
    scr_draw_box_split(sprite_index, image_index, x, y, image_xscale, image_yscale, split_axis, split_off_a, split_off_b, image_blend, image_alpha);
    exit;
}

// obj_battlebox's origin is top-left, but box_angle needs to rotate the
// sprite around its CENTER (like it's being spun in place), not its corner.
// So instead of just setting image_angle (which would rotate around the
// top-left origin and send the box swinging off to the side), we manually
// offset the draw position: find where the top-left corner needs to be
// drawn so that, once rotated, the visible center still lands exactly on
// the box's actual center point.
var _c = scr_box_center();
var _half_w = (raw_width  * image_xscale) / 2;
var _half_h = (raw_height * image_yscale) / 2;
var _off = scr_rotate_point(-_half_w, -_half_h, box_angle);

var _draw_x = _c.x + _off.x;
var _draw_y = _c.y + _off.y;

draw_sprite_ext(sprite_index, image_index, _draw_x, _draw_y, image_xscale, image_yscale, box_angle, image_blend, image_alpha);