switch (phase)
{
    case "telegraph":
        if (telegraph_inst == noone)
        {
            var _quadrants = ["tl", "tr", "bl", "br"];
            safe_quadrant = _quadrants[irandom(3)];

            telegraph_inst = instance_create_depth(0, 0, -390, obj_quadrant_highlight);
            telegraph_inst.safe_quadrant = safe_quadrant;
        }

        telegraph_timer--;
        if (telegraph_timer <= 0)
        {
            instance_destroy(telegraph_inst);
            telegraph_inst = noone;
            gavel_inst = scr_spawn_gavel_hammer(safe_quadrant);
            phase = "waiting";
        }
    break;

    case "waiting":
        if (!instance_exists(gavel_inst) && instance_number(obj_shockwave_ring) == 0)
        {
            repeat_count++;
            if (repeat_count >= max_repeats)
            {
                instance_destroy();
            }
            else
            {
                gap_timer = 60;
                phase = "gap";
            }
        }
    break;

    case "gap":
        gap_timer--;
        if (gap_timer <= 0)
        {
            telegraph_timer = 50;
            telegraph_inst = noone;
            phase = "telegraph";
        }
    break;
}