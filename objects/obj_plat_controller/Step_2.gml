// End Step: the camera, after everyone's moved this frame (it stays put during the fight)
if (!cam_locked)
{
    var _c = cam_target();
    if (wrap_on)
    {
        // centred on whoever you're controlling: they're the front of the tower (easing back in after the fight)
        if (cam_release > 0) { cam_release--; cam_x += scr_plat_wrap_dx(cam_x, _c.x) * 0.2; }
        else cam_x = _c.x;
    }
    else cam_x = lerp(cam_x, _c.x, cam_lerp);
    cam_y = lerp(cam_y, _c.y, cam_lerp);
}
var _rx = round(cam_x), _ry = round(cam_y);
camera_set_view_pos(view_camera[0], _rx, _ry);
if (instance_exists(obj_camera_controller)) { obj_camera_controller.cam_x = _rx; obj_camera_controller.cam_y = _ry; }