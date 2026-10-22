switch (phase)
{
    case "pick_tiles":
		tile_data = []; // clear leftover entries from the previous repeat
	    var _interior = scr_get_box_interior();
	    var _cols = 6;
	    var _strip_slot_w = (_interior.x2 - _interior.x1) / _cols;

	    var _indices = [];
	    for (var i = 0; i < _cols; i++)
	    {
	        array_push(_indices, i);
	    }

	    var _count = min(tiles_total, _cols);
	    for (var i = 0; i < _count; i++)
	    {
	        var _idx = irandom(array_length(_indices) - 1);
	        var _col = _indices[_idx];
	        array_delete(_indices, _idx, 1);

	        var _slot_x = _interior.x1 + _col * _strip_slot_w;
	        var _center_x = _slot_x + _strip_slot_w / 2;
	        var _strip_x = _center_x - strip_thin_width / 2;

	        var _warn = instance_create_depth(_strip_x, _interior.y1, -390, obj_tile_warning);
	        _warn.cell_w = strip_thin_width;
	        _warn.cell_h = _interior.y2 - _interior.y1;
	        _warn.hold_timer = warning_time - 15;

	        array_push(tile_data, { x: _center_x });
	    }

	    timer = warning_time;
	    phase = "warning";
	break;

    case "warning":
        timer--;
        if (timer <= 0)
        {
            for (var i = 0; i < array_length(tile_data); i++)
            {
                scr_spawn_falling_hammer(tile_data[i].x);
            }
            phase = "waiting_hammers";
        }
    break;

    case "waiting_hammers":
	    if (instance_number(obj_falling_hammer) == 0 && instance_number(obj_tile_warning) == 0)
	    {
	        repeat_count++;
	        if (repeat_count >= max_repeats)
	        {
	            instance_destroy();
	        }
	        else
	        {
	            gap_timer = 60; // ~1 second between repeats
	            phase = "gap";
	        }
	    }
	break;

	case "gap":
	    gap_timer--;
	    if (gap_timer <= 0)
	    {
	        phase = "pick_tiles";
	    }
	break;
}