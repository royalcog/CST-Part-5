if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
var _bb = obj_battlebox;

switch (state)
{
        case "shrink":
	        // glide to the middle of the bounce area while shrinking, carrying the soul along
	        var _old_x = _bb.x;
	        var _old_y = _bb.y;

	        _bb.box_base_x = lerp(_bb.box_base_x, center_base_x, 0.12);
	        _bb.box_base_y = lerp(_bb.box_base_y, center_base_y, 0.12);
	        _bb.x = _bb.box_base_x + (_bb.raw_width  - _bb.raw_width  * _bb.image_xscale) / 2;
	        _bb.y = _bb.box_base_y + (_bb.raw_height - _bb.raw_height * _bb.image_yscale) / 2;
	        if (instance_exists(obj_soul))
	        {
	            obj_soul.x += _bb.x - _old_x;
	            obj_soul.y += _bb.y - _old_y;
	        }

	        if (scr_box_scale_settled() && point_distance(_bb.box_base_x, _bb.box_base_y, center_base_x, center_base_y) < 1)
	        {
	            _bb.box_base_x = center_base_x;
	            _bb.box_base_y = center_base_y;

	            var _s  = box_scale;
	            var _iw = (_bb.raw_width  - 46) * _s;  // interior width  (15 pad + 8 border per side, same as scr_get_box_interior)
	            var _ih = (_bb.raw_height - 16) * _s;  // interior height (8 border top/bottom)
	            var _in_x = (23 - vis_pad_x) * _s;     // gap between the visible box edge and the interior
	            var _in_y = 8 * _s;

	            var _lx = wall_l + _in_x + spade_reach * _iw;
	            var _rx = wall_r - _in_x - spade_reach * _iw;
	            var _ty = wall_t + _in_y + spade_reach * _ih;
	            var _by = wall_b - _in_y - spade_reach * _ih;

	            var _step = spade_size + spade_gap;

	            // top + bottom rows (these own the corners)
	            var _n = max(1, round((_rx - _lx) / _step));
	            for (var i = 0; i <= _n; i++)
	            {
	                var _x = lerp(_lx, _rx, i / _n);
	                spawn_spade(_x, _ty);
	                spawn_spade(_x, _by);
	            }

	            // left + right columns (corners already placed above)
	            _n = max(1, round((_by - _ty) / _step));
	            for (var i = 1; i < _n; i++)
	            {
	                var _y = lerp(_ty, _by, i / _n);
	                spawn_spade(_lx, _y);
	                spawn_spade(_rx, _y);
	            }

	            timer = warmup_frames;
	            state = "warmup";
	        }
	    break;

    case "warmup":
        timer--;
        if (timer <= 0)
        {
            timer = 0;
            state = "bounce";
        }
    break;

    case "bounce":
        timer++;
        var _ramp = clamp(timer / speed_ramp_frames, 0, 1);
        _ramp = 1 - sqr(1 - _ramp); // ease-out: most of the speed-up happens early, then it levels off
        move_speed = lerp(speed_start, speed_max, _ramp);

        var _old_x = _bb.x;
        var _old_y = _bb.y;

        _bb.box_base_x += lengthdir_x(move_speed, move_dir);
        _bb.box_base_y += lengthdir_y(move_speed, move_dir);

        // visible box edges at the current scale
        var _sx = _bb.image_xscale;
        var _sy = _bb.image_yscale;
        var _bx = _bb.box_base_x + (_bb.raw_width  - _bb.raw_width  * _sx) / 2;
        var _by2 = _bb.box_base_y + (_bb.raw_height - _bb.raw_height * _sy) / 2;
        var _left   = _bx + vis_pad_x * _sx;
        var _right  = _bx + (_bb.raw_width - vis_pad_x) * _sx;
        var _top    = _by2;
        var _bottom = _by2 + _bb.raw_height * _sy;

        // DVD-logo bounce: push back inside and mirror the direction
        var _bounced = false;
        if (_left < wall_l)        { _bb.box_base_x += wall_l - _left;    move_dir = 180 - move_dir; _bounced = true; }
        else if (_right > wall_r)  { _bb.box_base_x -= _right - wall_r;   move_dir = 180 - move_dir; _bounced = true; }
        if (_top < wall_t)         { _bb.box_base_y += wall_t - _top;     move_dir = -move_dir;      _bounced = true; }
        else if (_bottom > wall_b) { _bb.box_base_y -= _bottom - wall_b;  move_dir = -move_dir;      _bounced = true; }

        if (_bounced && bounce_sound != -1) audio_play_sound(bounce_sound, 5, false); // corner hits only play once

        // apply now (same formula obj_battlebox uses) and carry the soul along with it
        _bb.x = _bb.box_base_x + (_bb.raw_width  - _bb.raw_width  * _sx) / 2;
        _bb.y = _bb.box_base_y + (_bb.raw_height - _bb.raw_height * _sy) / 2;
        if (instance_exists(obj_soul))
        {
            obj_soul.x += _bb.x - _old_x;
            obj_soul.y += _bb.y - _old_y;
        }

        if (timer >= bounce_duration)
        {
            with (obj_spade_border) fading_out = true;
            _bb.target_scale_x = 1;
            _bb.target_scale_y = 1;
            state = "wind_down";
        }
    break;

    // spades fade, box glides back to where it opened and grows back to full size
    case "wind_down":
        var _old_x = _bb.x;
        var _old_y = _bb.y;

        _bb.box_base_x = lerp(_bb.box_base_x, start_base_x, 0.1);
        _bb.box_base_y = lerp(_bb.box_base_y, start_base_y, 0.1);
        _bb.x = _bb.box_base_x + (_bb.raw_width  - _bb.raw_width  * _bb.image_xscale) / 2;
        _bb.y = _bb.box_base_y + (_bb.raw_height - _bb.raw_height * _bb.image_yscale) / 2;
        if (instance_exists(obj_soul))
        {
            obj_soul.x += _bb.x - _old_x;
            obj_soul.y += _bb.y - _old_y;
        }

        if (instance_number(obj_spade_border) == 0
         && point_distance(_bb.box_base_x, _bb.box_base_y, start_base_x, start_base_y) < 1
         && scr_box_scale_settled())
        {
            _bb.box_base_x = start_base_x;
            _bb.box_base_y = start_base_y;
            instance_destroy();
        }
    break;
}