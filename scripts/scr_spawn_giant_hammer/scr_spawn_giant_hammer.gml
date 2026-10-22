function scr_spawn_giant_hammer(_side)
{
    var _interior = scr_get_box_interior();
    var _outside_gap = -20;
    var _hammer_scale = 2.5;

    var _pivot_data = {
	    left:  { x: _interior.x1 - _outside_gap, y: _interior.y2, start_angle: 90,  end_angle: -270 }, // clockwise
	    right: { x: _interior.x2 + _outside_gap, y: _interior.y2, start_angle: 90,  end_angle: 450 },  // counterclockwise
	    up:    { x: _interior.x1, y: _interior.y1 - _outside_gap, start_angle: 0,   end_angle: -360 }, // clockwise
	    down:  { x: _interior.x2, y: _interior.y2 + _outside_gap, start_angle: 180, end_angle: -180 }  // clockwise
	};

    var _d = variable_struct_get(_pivot_data, _side);

    var _h = instance_create_depth(_d.x, _d.y, -220, obj_giant_hammer);
    _h.image_xscale = _hammer_scale;
    _h.image_yscale = _hammer_scale;
    _h.start_angle = _d.start_angle;
    _h.end_angle = _d.end_angle;
    _h.image_angle = _d.start_angle;
    _h.reach = 100 * _hammer_scale; // used for the visibility check below

    return _h;
}