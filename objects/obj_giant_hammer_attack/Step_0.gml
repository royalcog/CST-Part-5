switch (phase)
{
    case "start":
        var _sides = ["left", "right", "up", "down"];
        side = _sides[irandom(3)];

        var _land_map = { left: "down", up: "right", right: "up", down: "left" };
        land_side = variable_struct_get(_land_map, side);

        var _snd_map = {
            left: snd_soundbattle_leftblock,
            right: snd_soundbattle_rightblock,
            up: snd_soundbattle_upblock,
            down: snd_soundbattle_downblock
        };
        audio_play_sound(variable_struct_get(_snd_map, side), 5, false);

        var _flash = instance_create_depth(0, 0, -400, obj_edge_flash);
        _flash.side = side;

        timer = 30; // "a few milliseconds later" — tune to taste
        phase = "wait_for_box_flash";
    break;

    case "wait_for_box_flash":
	    timer--;
	    if (timer <= 0)
	    {
	        var _opposite_map = { left: "right", right: "left", up: "down", down: "up" };
	        var _safe_side = variable_struct_get(_opposite_map, side);

	        var _box_flash = instance_create_depth(0, 0, -390, obj_box_red_flash);
	        _box_flash.exclude_side = _safe_side;

	        timer = 90;
	        phase = "wait_for_hammer";
	    }
	break;

    case "wait_for_hammer":
	    timer--;
	    if (timer <= 0)
	    {
	        scr_spawn_giant_hammer(side);
	        phase = "waiting_hammer_done";
	    }
	break;

    case "waiting_hammer_done":
	    if (!instance_exists(obj_giant_hammer))
	    {
	        repeat_count++;
	        if (repeat_count >= max_repeats)
	        {
	            instance_destroy();
	        }
	        else
	        {
	            timer = 20; // brief gap before the next one starts
	            phase = "between_repeats";
	        }
	    }
	break;

	case "between_repeats":
	    timer--;
	    if (timer <= 0)
	    {
	        phase = "start";
	    }
	break;
}