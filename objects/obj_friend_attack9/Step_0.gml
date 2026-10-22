switch (phase)
{
    case "grab":
        if (instance_exists(hand_left))  hand_left.image_alpha  = min(hand_left.image_alpha  + hand_fade_speed, 1);
        if (instance_exists(hand_right)) hand_right.image_alpha = min(hand_right.image_alpha + hand_fade_speed, 1);

        if ((!instance_exists(hand_left)  || hand_left.image_alpha  >= 1) &&
            (!instance_exists(hand_right) || hand_right.image_alpha >= 1))
        {
            audio_play_sound(snd_impact, 5, false);
            scr_camera_shake(shake_intensity, shake_duration);
            shake_timer = shake_duration;

            // hands visibly rattle in place while the box shakes, instead
            // of just riding along with the camera shake indirectly
            if (instance_exists(hand_left))  hand_left.shake_jitter_amount  = shake_intensity;
            if (instance_exists(hand_right)) hand_right.shake_jitter_amount = shake_intensity;

            phase = "shake";
        }
    break;

    case "shake":
        shake_timer--;
        if (shake_timer <= 0)
        {
            // stop the jitter — the tear phase below takes over hand
            // position directly, and the two would otherwise fight
            if (instance_exists(hand_left))  hand_left.shake_jitter_amount  = 0;
            if (instance_exists(hand_right)) hand_right.shake_jitter_amount = 0;

            // capture the box's current look right as we start tearing it,
            // then hide the real instance (sequencer still owns its actual
            // lifetime) and draw our own splitting halves in its place
            if (instance_exists(obj_battlebox))
            {
                tear_sprite       = obj_battlebox.sprite_index;
                tear_image_index  = obj_battlebox.image_index;
                tear_raw_w        = obj_battlebox.raw_width;
                tear_raw_h        = obj_battlebox.raw_height;
                tear_xscale       = obj_battlebox.image_xscale;
                tear_yscale       = obj_battlebox.image_yscale;
                tear_base_x       = obj_battlebox.x;
                tear_base_y       = obj_battlebox.y;
                obj_battlebox.visible = false;
            }

            hand_left_start_x  = instance_exists(hand_left)  ? hand_left.x  : tear_base_x;
            hand_right_start_x = instance_exists(hand_right) ? hand_right.x : (tear_base_x + tear_raw_w * tear_xscale);

            timer = 0;
            phase = "tear";
        }
    break;

    case "tear":
        timer++;

        var _t = clamp(timer / tear_duration, 0, 1);
        tear_split = lerp(0, 220, _t);

        if (instance_exists(hand_left))  hand_left.x  = hand_left_start_x  - tear_split;
        if (instance_exists(hand_right)) hand_right.x = hand_right_start_x + tear_split;

        if (timer >= tear_duration)
        {
            if (instance_exists(hand_left))  instance_destroy(hand_left);
            if (instance_exists(hand_right)) instance_destroy(hand_right);
            phase = "dark_in";
        }
    break;

    case "dark_in":
        if (instance_exists(obj_lighting))
        {
            prev_darkness_left  = obj_lighting.darkness_target_left;
            prev_darkness_right = obj_lighting.darkness_target_right;

            dark_fade_start_left  = obj_lighting.darkness_alpha_left;
            dark_fade_start_right = obj_lighting.darkness_alpha_right;

            obj_lighting.darkness_target_left  = 1;
            obj_lighting.darkness_target_right = 1;

            dark_active = true;
        }

        // kill every active personal light so nothing stays visible
        // through a punched-out circle while we fade
        saved_light_states = [];
        var _n = instance_number(obj_light_source);
        for (var i = 0; i < _n; i++)
        {
            var _inst = instance_find(obj_light_source, i);
            array_push(saved_light_states, { inst: _inst, was_on: _inst.light_on });
            _inst.light_on = false;
        }

        dark_fade_timer = 0;
        phase = "dark_fading_in";
    break;

    case "dark_fading_in":
        dark_fade_timer++;
        var _ft = clamp(dark_fade_timer / dark_fade_duration, 0, 1);

        if (instance_exists(obj_lighting))
        {
            obj_lighting.darkness_alpha_left  = lerp(dark_fade_start_left,  1, _ft);
            obj_lighting.darkness_alpha_right = lerp(dark_fade_start_right, 1, _ft);
        }

        if (_ft >= 1)
        {
            phase = "combo";
        }
    break;

    case "combo":
        if (!combo_started)
        {
            combo_started = true;

            // tail: the same Attack 4 pendulum, just scaled up so its swing
            // reaches clear across the screen instead of just the box —
            // scale is derived from the actual view width so it always
            // covers the full screen regardless of resolution
            var _view_w = camera_get_view_width(view_camera[0]);
            var _tail_raw_h = sprite_get_height(spr_friend_tail);
            var _big_scale = _view_w / _tail_raw_h;

            tail_inst = instance_create_depth(0, 0, -370, obj_friend_attack4, {
                scale_override: _big_scale,
                duration_override: total_dark_frames - dark_timer,
                pivot_at_screen_center: true
            });

            scissors_inst = instance_create_depth(0, 0, -380, obj_friend_attack_scissors_solo, { duration: total_dark_frames - dark_timer });
        }

        dark_timer++;

        if (dark_timer >= total_dark_frames)
        {
            if (instance_exists(tail_inst))     instance_destroy(tail_inst);
            if (instance_exists(scissors_inst)) instance_destroy(scissors_inst);
            with (obj_friend_hand_punch) instance_destroy();
            with (obj_strip_flash)       instance_destroy();

            phase = "dark_out";
        }
    break;

    case "dark_out":
        if (instance_exists(obj_soul)) instance_destroy(obj_soul);
        if (instance_exists(obj_battlebox)) obj_battlebox.visible = true;

        for (var i = 0; i < array_length(saved_light_states); i++)
        {
            var _entry = saved_light_states[i];
            if (instance_exists(_entry.inst)) _entry.inst.light_on = _entry.was_on;
        }

        if (instance_exists(obj_lighting))
        {
            obj_lighting.darkness_target_left  = prev_darkness_left;
            obj_lighting.darkness_target_right = prev_darkness_right;
        }

        instance_destroy();
    break;
}