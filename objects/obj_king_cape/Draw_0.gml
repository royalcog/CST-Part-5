if (!dark)
{
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_white, 1);
    exit;
}

var _cam = view_camera[0];
var _vx = camera_get_view_x(_cam);
var _vy = camera_get_view_y(_cam);
var _vw = camera_get_view_width(_cam);
var _vh = camera_get_view_height(_cam);

draw_set_color(c_black);
draw_rectangle(_vx, _vy, _vx + _vw, _vy + _vh, false);

shader_set(shd_silhouette_white);

if (instance_exists(obj_king))
{
    draw_sprite_ext(obj_king.sprite_index, obj_king.image_index, obj_king.x, obj_king.y,
        obj_king.image_xscale, obj_king.image_yscale, obj_king.image_angle, c_white, 1);
}

draw_sprite_ext(sprite_index, image_index, x, y,
    image_xscale, image_yscale, image_angle, c_white, 1);

shader_reset();