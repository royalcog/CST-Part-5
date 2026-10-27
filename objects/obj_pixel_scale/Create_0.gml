// draws the game at an exact whole-number scale, centred in a full-size window with black bars
// (853x480 at 2x = 1706x960 inside 1920x1080). the window stays full size so Windows treats it like fullscreen
// (no lag), and the GUI (text, UI boxes, TP bar) gets the same exact scale, lined up with the picture.
// to go back to how it was: set enabled = false
enabled = true;

scale  = 1;      // the picture's scale...
ox     = 0;      // ...and its top-left in the window
oy     = 0;
last_w = 0;
last_h = 0;
gui_cam = camera_create();

/// works out the scale + bars for the window's size, and sizes the view port, app surface and GUI to match
apply = function()
{
    var _vw = camera_get_view_width(view_camera[0]);
    var _vh = camera_get_view_height(view_camera[0]);
    display_set_gui_size(_vw, _vh);   // GUI code still works in 853x480
    if (!enabled) return;

    var _ww = max(1, window_get_width()), _wh = max(1, window_get_height());
    scale = max(1, floor(min(_ww / _vw, _wh / _vh)));
    var _w = _vw * scale, _h = _vh * scale;
    ox = floor((_ww - _w) / 2 / scale) * scale;   // a whole GUI pixel in, so the GUI lines up exactly
    oy = floor((_wh - _h) / 2 / scale) * scale;

    view_xport[0] = 0;  view_yport[0] = 0;
    view_wport[0] = _w; view_hport[0] = _h;
    if (surface_get_width(application_surface) != _w || surface_get_height(application_surface) != _h)
        surface_resize(application_surface, _w, _h);

    // the GUI: one GUI px = scale window px, with (0, 0) on the picture's corner
    var _gw = _ww / scale, _gh = _wh / scale;
    var _cx = -ox / scale + _gw / 2, _cy = -oy / scale + _gh / 2;
    camera_set_view_mat(gui_cam, matrix_build_lookat(_cx, _cy, -10, _cx, _cy, 0, 0, 1, 0));
    camera_set_proj_mat(gui_cam, matrix_build_projection_ortho(_gw, _gh, 1, 32000));

    last_w = _ww;
    last_h = _wh;
}

// the window back to full size (the last version shrank it)
if (enabled && !window_get_fullscreen())
{
    window_set_size(display_get_width(), display_get_height());
    call_later(2, time_source_units_frames, window_center);
}
apply();