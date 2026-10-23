// one of rm_tower's tile layers again, one tower-width to the left and to the right,
// so the wrap-around has something to show when you're near the seam (made by obj_plat_controller)
var _w = scr_plat_wrap_w();
if (_w <= 0 || tm == -1) exit;
draw_tilemap(tm, -_w, 0);
draw_tilemap(tm,  _w, 0);