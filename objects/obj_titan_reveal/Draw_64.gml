// the screen afterimage as the wings open (Ch4's obj_afterimage_screen): a copy of the whole screen that
// grows out from a point on the right and fades
var _gw = display_get_gui_width(), _gh = display_get_gui_height();

if (after_grab)
{
    after_grab = false;
    var _w = surface_get_width(application_surface), _h = surface_get_height(application_surface);
    if (!surface_exists(after_surf)) after_surf = surface_create(_w, _h);
    surface_copy(after_surf, 0, 0, application_surface);
    after_on    = true;
    after_scale = 1;
    after_alpha = 0.5;
}

if (after_on && surface_exists(after_surf))
{
    var _k  = _gw / surface_get_width(after_surf);     // the surface is at window size, the GUI at view size
    var _ax = _gw - afterimage_anchor_from_right;
    var _ay = afterimage_anchor_y;
    var _s  = after_scale;
    draw_surface_ext(after_surf, _ax - _ax * _s, _ay - _ay * _s, _k * _s, _k * _s, 0, c_white, after_alpha);
}