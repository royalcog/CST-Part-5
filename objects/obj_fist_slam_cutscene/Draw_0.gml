var _cam = view_camera[0];
var _vx = camera_get_view_x(_cam);
var _vy = camera_get_view_y(_cam);
var _vw = camera_get_view_width(_cam);
var _vh = camera_get_view_height(_cam);

if (darken_alpha > 0)
{
    draw_set_alpha(darken_alpha);
    draw_set_color(c_black);
    draw_rectangle(_vx, _vy, _vx + _vw, _vy + _vh, false);
    draw_set_alpha(1);
}

if (phase == "rush")
{
    shader_set(shd_silhouette_white);
    if (instance_exists(target_inst))
    {
        draw_sprite_ext(target_inst.sprite_index, target_inst.image_index, target_inst.x, target_inst.y,
            target_inst.image_xscale, target_inst.image_yscale, target_inst.image_angle, c_white, 1);
    }
    draw_sprite_ext(fist_sprite, 0, fist_room_x, fist_room_y, image_xscale, image_yscale, 0, c_white, 1);
    shader_reset();
}
else if (phase == "impact" || phase == "hold" || phase == "split_move" || phase == "split_fade")
{
    draw_sprite_ext(fist_sprite, 0, fist_room_x, fist_room_y, image_xscale, image_yscale, 0, c_white, alpha);
}