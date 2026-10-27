/// where the game's picture sits in the window: [x1, y1, x2, y2] (same shape as application_get_position)
function scr_pixel_rect()
{
    if (!instance_exists(obj_pixel_scale) || !obj_pixel_scale.enabled) return application_get_position();
    var _p = instance_find(obj_pixel_scale, 0);
    return [_p.ox, _p.oy, _p.ox + surface_get_width(application_surface), _p.oy + surface_get_height(application_surface)];
}

/// puts the exact-scale GUI back. call it after anything in Draw GUI changes the drawing target (surface_reset_target)
function scr_gui_reapply()
{
    if (instance_exists(obj_pixel_scale) && obj_pixel_scale.enabled) camera_apply(obj_pixel_scale.gui_cam);
}