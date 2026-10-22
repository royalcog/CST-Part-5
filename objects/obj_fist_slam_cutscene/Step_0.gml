switch (phase)
{
    case "darken":
        darken_alpha += darken_speed;
        if (darken_alpha >= 1)
        {
            darken_alpha = 1;
            phase = "rush";

            var _cam = view_camera[0];
            var _vx = camera_get_view_x(_cam);
            var _vw = camera_get_view_width(_cam);

            if (spawn_side == "left")
            {
                fist_room_x = _vx - spawn_margin; // left edge of the screen
                image_xscale = scale; // sprite faces right by default — that already matches travel direction (right) when coming from the left
            }
            else
            {
                fist_room_x = _vx + _vw + spawn_margin; // right edge of the screen
                image_xscale = -scale; // sprite faces right by default — flip to face the punch direction (left)
            }
            image_yscale = scale;

            fist_room_y = target_inst.y + fist_y_offset;
            fist_start_x = fist_room_x;
            fist_slow_x = target_inst.x + ((fist_start_x - target_inst.x) / 2);

            if (instance_exists(target_inst))
            {
                target_inst.visible = false; // we draw a white silhouette copy of it ourselves below
            }
        }
    break;

    case "rush":
	    var _approaching = (spawn_side == "left") ? (fist_room_x < fist_slow_x) : (fist_room_x > fist_slow_x);
	    var _speed = _approaching ? fast_speed : slow_speed;
	    fist_room_x += (spawn_side == "left") ? _speed : -_speed;

	    var _reached = (spawn_side == "left")
	        ? (fist_room_x >= target_inst.x - hit_offset)
	        : (fist_room_x <= target_inst.x + hit_offset);

	    if (_reached)
	    {
	        fist_room_x = target_inst.x + ((spawn_side == "left") ? -hit_offset : hit_offset);
	        phase = "impact";
	        audio_stop_all();
	        audio_play_sound(snd_impact, 1, false);

	        knockback_dir = point_direction(fist_start_x, fist_room_y, target_inst.x, target_inst.y);
	        knockback_speed = knockback_max;

	        if (instance_exists(target_inst))
	        {
	            target_inst.visible = true;
	        }
	        if (instance_exists(obj_mewmew))
	        {
	            obj_mewmew.sprite_index = spr_mewmew_shocked_backwards_corrupted;
	        }
	    }
	break;

    case "impact":
        darken_alpha -= darken_speed * 2;
        if (darken_alpha < 0) darken_alpha = 0;

        if (instance_exists(target_inst))
        {
            target_inst.x += lengthdir_x(knockback_speed, knockback_dir);
            target_inst.y += lengthdir_y(knockback_speed, knockback_dir);
        }
        knockback_speed -= knockback_friction;
        if (knockback_speed < 0) knockback_speed = 0;

        if (knockback_speed <= 0)
		{
		    phase = "hold";
		    punch_complete = true;
		    fist_base_y = fist_room_y;
		    bob_timer = 0;
		}
    break;

    case "hold":
	    if (bob_enabled)
	    {
	        bob_timer += bob_speed;
	        fist_room_y = fist_base_y + sin(bob_timer) * bob_amount;
	    }
	break;
	
	case "split_move":
        fist_room_x = lerp(fist_room_x, split_target_x, split_move_lerp);
        if (abs(fist_room_x - split_target_x) < 1)
        {
            fist_room_x = split_target_x;
            fist_base_y = fist_room_y;
            phase = "hold";

            // arrived — now spawn the mirrored clone, faded out, to fade in in place
            var _clone = instance_create_depth(0, 0, depth, obj_fist_slam_cutscene);
            _clone.target_inst     = target_inst;
            _clone.fist_sprite     = fist_sprite;
            _clone.phase           = "split_fade";
            _clone.fist_room_x     = split_mirror_x;
            _clone.fist_room_y     = fist_room_y;
            _clone.fist_base_y     = fist_room_y;
            _clone.image_xscale    = -image_xscale; // inverted, mirrors the original
            _clone.image_yscale    = image_yscale;
            _clone.bob_enabled     = bob_enabled;
            _clone.bob_amount      = bob_amount;
            _clone.bob_speed       = bob_speed;
            _clone.darken_alpha    = 0;              // don't re-darken the screen
            _clone.punch_complete  = true;
            _clone.explosion_played = true;          // don't replay snd_explosion for the clone
            _clone.alpha           = 0;
            _clone.split_fade_speed = split_fade_speed;
        }
    break;

    case "split_fade":
        alpha += split_fade_speed;
        if (alpha >= 1)
        {
            alpha = 1;
            phase = "hold";
        }
    break;
}

// tracks the target leaving the screen, regardless of impact/hold phase, to time the explosion
if ((phase == "impact" || phase == "hold") && instance_exists(target_inst) && !explosion_played)
{
    var _cam = view_camera[0];
    var _onscreen = (target_inst.x > camera_get_view_x(_cam) - 50
        && target_inst.x < camera_get_view_x(_cam) + camera_get_view_width(_cam) + 50);

    if (!_onscreen)
    {
        offscreen_timer++;
        if (offscreen_timer >= offscreen_wait)
        {
            audio_play_sound(snd_explosion, 1, false);
            explosion_played = true;
        }
    }
}