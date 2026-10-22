function scr_spawn_soj_hit_hammer()
{
    var _vx = camera_get_view_x(view_camera[0]);
    var _vy = camera_get_view_y(view_camera[0]);
    var _start_x = _vx - 100; // off-screen left
    var _start_y = obj_sound_of_justice.y;

    var _h = instance_create_depth(_start_x, _start_y, -220, obj_soj_hit_hammer);
	_h.image_xscale = 2;
	_h.image_yscale = 2;
	_h.start_x = _start_x;
	_h.start_y = _start_y;
	_h.target_x = obj_sound_of_justice.x;
	_h.target_y = obj_sound_of_justice.y - 30;

    return _h;
}