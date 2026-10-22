function scr_spawn_battlebox(_x_nudge = 0)
{
    var _cam = view_camera[0];
    var _view_w = camera_get_view_width(_cam);
    var _view_h = camera_get_view_height(_cam);

    // where the camera actually is (ignoring any screen-shake offset), so the box
    // centers on the SCREEN, not on the room
    var _view_x = instance_exists(obj_camera_controller) ? obj_camera_controller.cam_x : camera_get_view_x(_cam);
    var _view_y = instance_exists(obj_camera_controller) ? obj_camera_controller.cam_y : camera_get_view_y(_cam);

    var _box_x = _view_x + (_view_w - sprite_get_width(spr_battlebox)) / 2 + _x_nudge;
    var _box_y = _view_y + (_view_h * 0.35) - (sprite_get_height(spr_battlebox) / 2) + 50;

    return instance_create_depth(_box_x, _box_y, -200, obj_battlebox);
}