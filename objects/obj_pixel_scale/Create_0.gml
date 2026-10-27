// draws the game at an exact whole-number scale (853x480 at 2x = 1706x960 on a 1080p screen) so pixel art and
// text come out even (before, everything was stretched 2.25x into 1920x1080).
// to go back to how it was: set enabled = false
enabled = true;
margin  = 80;   // screen height kept free for the title bar + taskbar when picking the scale

apply = function()
{
    if (!enabled) return;
    var _vw = camera_get_view_width(view_camera[0]);
    var _vh = camera_get_view_height(view_camera[0]);
    var _s  = max(1, floor(min(display_get_width() / _vw, (display_get_height() - margin) / _vh)));
    var _w  = _vw * _s, _h = _vh * _s;

    view_xport[0] = 0;  view_yport[0] = 0;
    view_wport[0] = _w; view_hport[0] = _h;
    if (surface_get_width(application_surface) != _w || surface_get_height(application_surface) != _h)
        surface_resize(application_surface, _w, _h);
    if (!window_get_fullscreen() && (window_get_width() != _w || window_get_height() != _h))
    {
        window_set_size(_w, _h);
        call_later(2, time_source_units_frames, window_center);
    }
    display_set_gui_size(_vw, _vh);
}
apply();