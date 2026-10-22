switch (phase)
{
    case "hands_in":
        if (instance_exists(hand_left))  hand_left.image_alpha  = min(hand_left.image_alpha  + hand_fade_speed, 1);
        if (instance_exists(hand_right)) hand_right.image_alpha = min(hand_right.image_alpha + hand_fade_speed, 1);

        if ((!instance_exists(hand_left)  || hand_left.image_alpha  >= 1) &&
            (!instance_exists(hand_right) || hand_right.image_alpha >= 1))
        {
            audio_play_sound(snd_impact, 5, false);

            // yarn starts falling in right as the box begins to turn
            if (instance_exists(obj_battlebox))
			{
			    // spawn already inside the box interior, roughly toward
			    // the upper-middle so it has room to bounce down and
			    // around — no need to fall in from off-screen first
			    var _interior = scr_get_box_interior();
			    var _spawn_x = lerp(_interior.x1, _interior.x2, 0.5) + random_range(-40, 40);
			    var _spawn_y = lerp(_interior.y1, _interior.y2, 0.3);
			    yarn = instance_create_depth(_spawn_x, _spawn_y, -370, obj_yarn);
			}

            timer = 0;
            phase = "spin_up";
        }
    break;

    case "spin_up":
        timer++;
        var _t = clamp(timer / ramp_duration, 0, 1);
        angular_speed = lerp(0, max_angular_speed, _t);

        if (instance_exists(hand_left))  hand_left.image_speed  = lerp(0, max_hand_image_speed, _t);
        if (instance_exists(hand_right)) hand_right.image_speed = lerp(0, max_hand_image_speed, _t);

        if (instance_exists(obj_battlebox)) obj_battlebox.box_angle += angular_speed;

        if (_t >= 1)
        {
            timer = 0;
            phase = "spinning";
        }
    break;

    case "spinning":
        angular_speed = max_angular_speed;
        if (instance_exists(hand_left))  hand_left.image_speed  = max_hand_image_speed;
        if (instance_exists(hand_right)) hand_right.image_speed = max_hand_image_speed;

        if (instance_exists(obj_battlebox)) obj_battlebox.box_angle += angular_speed;

        timer++;
        if (timer >= spin_duration)
        {
            timer = 0;
            phase = "spin_down";
        }
    break;

    case "spin_down":
        timer++;
        var _t2 = clamp(timer / ramp_duration, 0, 1);
        angular_speed = lerp(max_angular_speed, 0, _t2);

        if (instance_exists(hand_left))  hand_left.image_speed  = lerp(max_hand_image_speed, 0, _t2);
        if (instance_exists(hand_right)) hand_right.image_speed = lerp(max_hand_image_speed, 0, _t2);

        if (instance_exists(obj_battlebox)) obj_battlebox.box_angle += angular_speed;

        if (_t2 >= 1)
        {
            timer = 0;
            phase = "settling";
        }
    break;

    case "settling":
        // ease the last bit of spin back to a clean, upright angle so the
        // box visibly settles back into "its normal shape" rather than
        // stopping wherever it happened to be
        if (instance_exists(obj_battlebox))
        {
            settle_target = round(obj_battlebox.box_angle / 360) * 360;
            obj_battlebox.box_angle = lerp(obj_battlebox.box_angle, settle_target, 0.15);

            if (abs(obj_battlebox.box_angle - settle_target) < 0.5)
            {
                obj_battlebox.box_angle = 0;
                phase = "hands_out";
            }
        }
        else
        {
            phase = "hands_out";
        }
    break;

    case "hands_out":
        if (instance_exists(yarn)) { instance_destroy(yarn); yarn = noone; }

        if (instance_exists(hand_left))  hand_left.image_alpha  = max(hand_left.image_alpha  - hand_fade_speed, 0);
        if (instance_exists(hand_right)) hand_right.image_alpha = max(hand_right.image_alpha - hand_fade_speed, 0);

        if ((!instance_exists(hand_left)  || hand_left.image_alpha  <= 0) &&
            (!instance_exists(hand_right) || hand_right.image_alpha <= 0))
        {
            instance_destroy();
        }
    break;
}