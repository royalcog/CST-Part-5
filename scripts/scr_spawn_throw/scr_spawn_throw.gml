function scr_spawn_throw(_target_inst, _throw)
{
    var _start_x, _start_y;
    if (_throw.mode == "arc" || _throw.mode == "straight")
    {
        var _src = _throw.source_obj;
        _start_x = instance_exists(_src) ? _src.x + _throw.spawn_offset_x : _target_inst.x;
        _start_y = instance_exists(_src) ? _src.y + _throw.spawn_offset_y : _target_inst.y;
    }
    else
    {
        var _cam = view_camera[0];
        var _vx = camera_get_view_x(_cam);
        var _vy = camera_get_view_y(_cam);
        var _vw = camera_get_view_width(_cam);
        var _vh = camera_get_view_height(_cam);
        var _m  = _throw.offscreen_margin;
        var _tx = _target_inst.x;
        var _ty = _target_inst.y;
        switch (_throw.direction)
        {
            case "left":  _start_x = _vx - _m;       _start_y = _ty;            break;
            case "right": _start_x = _vx + _vw + _m; _start_y = _ty;            break;
            case "up":    _start_x = _tx;            _start_y = _vy - _m;       break;
            case "down":  _start_x = _tx;            _start_y = _vy + _vh + _m; break;
            default:      _start_x = _vx - _m;       _start_y = _ty;            break;
        }
    }

    var _behind_depth = -1100;
	var _front_depth  = -1100;

	if ((_throw.mode == "arc" || _throw.mode == "straight") && instance_exists(_throw.source_obj))
	{
	    _behind_depth = _throw.source_obj.depth + 1; // just behind the thrower
	    _front_depth  = _target_inst.depth - 1;      // in front of the target
	}

	var _p = instance_create_depth(_start_x, _start_y, _behind_depth, obj_barrage_projectile);
    _p.sprite_index  = _throw.proj_sprite;
	_p.normal_sprite = _throw.proj_sprite;
    _p.image_xscale  = _throw.scale;
    _p.image_yscale  = _throw.scale;
    _p.mode          = _throw.mode;
    _p.start_x       = _start_x;
    _p.start_y       = _start_y;
    _p.target_inst   = _target_inst;
    var _hp = scr_get_hit_point(_target_inst);
    _p.target_x = _hp.x;
    _p.target_y = _hp.y;
    _p.animate       = _throw.animate;
    _p.spin_speed    = _throw.spin_speed;
    _p.damage_amount = _throw.damage_amount;
    _p.color_top     = _throw.color_top;
    _p.color_bottom  = _throw.color_bottom;
    _p.hit_radius    = _throw.hit_radius;
    _p.impact_sound  = _throw.impact_sound;
    _p.after_obj     = _throw.after_obj;
    _p.after_sprite  = _throw.after_sprite;
    _p.after_at      = _throw.after_at;
    _p.travel_sound     = _throw.travel_sound;
    _p.travel_sound_gap = _throw.travel_sound_gap;
	_p.beep_flash_sprite   = _throw.beep_flash_sprite;
	_p.beep_flash_duration = _throw.beep_flash_duration;
	_p.behind_depth      = _behind_depth;
	_p.front_depth       = _front_depth;
	_p.depth_switch_frac = _throw.depth_switch_frac;
	_p.depth_switched    = false;
    if (_throw.mode == "straight" && !_throw.animate)
    {
        _p.image_angle = point_direction(_start_x, _start_y, _p.target_x, _p.target_y);
    }

    if (_throw.mode == "directional")
    {
        var _dx = _p.target_x - _start_x;
        var _dy = _p.target_y - _start_y;
        var _len = point_distance(0, 0, _dx, _dy);
        _p.dir_x = (_len > 0) ? (_dx / _len) : 0;
        _p.dir_y = (_len > 0) ? (_dy / _len) : 0;
        _p.move_speed = _throw.move_speed;
    }
    else
    {
        _p.travel_time = _throw.travel_time;
        _p.arc_height  = _throw.arc_height;
        _p.timer = 0;
    }

    return _p;
}