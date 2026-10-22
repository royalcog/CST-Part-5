if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }

var _c = scr_box_center();
cx = _c.x;
cy = _c.y;

switch (state)
{
    case "windup":
        timer--;
        if (timer <= 0)
        {
            spawn_beam();
            if (start_sound != -1) audio_play_sound(start_sound, 5, false);
            scr_camera_shake(2, 10);
            storm_timer = 0;
            state = "storm";
        }
    break;

    case "storm":
        storm_timer++;
        apply_sway(1);

        // current spin target = last key we've passed
        var _target = spin_keys[0].spin;
        for (var i = 0; i < array_length(spin_keys); i++)
        {
            if (storm_timer >= spin_keys[i].at) _target = spin_keys[i].spin;
        }

        // direction flip = little jolt so the player notices
        if (sign(_target) != sign(last_target_spin))
        {
            if (reverse_sound != -1) audio_play_sound(reverse_sound, 5, false);
            scr_camera_shake(reverse_shake, 8);
        }
        last_target_spin = _target;

        cur_spin = lerp(cur_spin, _target, spin_ease);
        beam_angle += cur_spin;
        update_beam();

        sniper_timer--;
        if (sniper_timer <= 0)
        {
            spawn_sniper();
            sniper_timer = round(lerp(sniper_gap_start, sniper_gap_end, clamp(storm_timer / beam_duration, 0, 1)));
        }

        if (storm_timer >= beam_duration)
        {
            for (var i = 0; i < array_length(beam); i++)
            {
                if (instance_exists(beam[i].inst)) beam[i].inst.fading_out = true;
            }
            timer = end_delay;
            state = "end_hold";
        }
    break;

    // beam keeps turning (slowing down) while it fades, sway shrinks to exactly 0 before the box closes
    case "end_hold":
        storm_timer++;
        apply_sway(max(timer - 1, 0) / end_delay);

        cur_spin = lerp(cur_spin, 0, 0.08);
        beam_angle += cur_spin;
        update_beam();

        timer--;
        if (timer <= 0)
        {
            obj_battlebox.box_angle = 0;
            instance_destroy();
        }
    break;
}