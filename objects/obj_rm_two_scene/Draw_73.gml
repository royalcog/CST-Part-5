// the white streak as they drop: a full-height slanted bar sweeping left to right, then fading.
// in Draw End so it's on top of the Knight and everyone else
if (flash_t >= 0)
{
    var _vt = camera_get_view_y(view_camera[0]);
    var _vb = _vt + camera_get_view_height(view_camera[0]);
    var _cx = (sword_x_from + sword_x_to) / 2;
    var _x  = lerp(_cx - flash_sweep, _cx + flash_sweep, flash_t / flash_time);
    var _a  = (flash_t < flash_solid) ? 1 : 1 - (flash_t - flash_solid) / (flash_time - flash_solid);
    var _hw = flash_w / 2;
    gpu_set_blendmode(bm_normal);
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_x - _hw - flash_skew, _vt, c_white, _a);
    draw_vertex_colour(_x + _hw - flash_skew, _vt, c_white, _a);
    draw_vertex_colour(_x - _hw + flash_skew, _vb, c_white, _a);
    draw_vertex_colour(_x + _hw + flash_skew, _vb, c_white, _a);
    draw_primitive_end();
}