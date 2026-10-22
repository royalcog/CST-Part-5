if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }

switch (state)
{
    case "start":
        timer--;
        if (timer <= 0)
        {
            spawn_wave(waves[wave_index]);
            state = "wave_wait";
        }
    break;

    case "wave_wait":
        if (all_fired())
        {
            wave_index++;
            if (wave_index >= array_length(waves))
            {
                timer = end_delay;
                state = "end_hold";
            }
            else
            {
                timer = wave_pause;
                state = "start";
            }
        }
    break;

    // box closes on the last wave while it's still flying, like the other attacks
    case "end_hold":
        timer--;
        if (timer <= 0) instance_destroy();
    break;
}