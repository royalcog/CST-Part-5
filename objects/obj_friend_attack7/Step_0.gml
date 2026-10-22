switch (phase)
{
    case "dialogue":
        if (!dialogue_started)
        {
            dialogue_started = true;
            dialogue_inst = instance_create_depth(0, 0, 0, obj_dialogue_chain);
            dialogue_inst.batches = [
                [ { speaker: obj_friend, text: "If gravity doesn't need to abide, why should you?", keep_animating: true } ]
            ];
        }
        else if (!instance_exists(dialogue_inst))
        {
            phase = "waiting_shrink";
        }
    break;

    case "waiting_shrink":
        if (scr_box_scale_settled())
        {
            phase = "shake";
            scr_camera_shake(shake_intensity, shake_duration);
            timer = shake_duration;
        }
    break;

    case "shake":
        timer--;
        if (timer <= 0)
        {
            phase = "flipping";
            scr_screen_flip_to(180, flip_duration);
        }
    break;

    case "flipping":
        if (!scr_screen_flip_busy())
        {
            if (instance_exists(obj_mewmew))
            {
                obj_mewmew.sprite_index = spr_mewmew_shocked_backwards_corrupted;
                obj_mewmew.image_index  = 0;
                obj_mewmew.image_speed  = 0; // static pose, not animating
            }

            // no laugh in this attack — restore Friend's pose and hand off
            // to Attack 5 immediately instead of waiting on obj_friend_laugh_attack
            if (instance_exists(obj_friend))
            {
                obj_friend.sprite_index = friend_restore_sprite;
                obj_friend.image_index  = 0;
                obj_friend.image_speed  = friend_restore_speed;
            }

            // obj_friend_attack5 expects a normal, full-size box
            if (instance_exists(obj_battlebox)) obj_battlebox.target_scale_y = 1;

            // camera starts rocking like a pendulum the moment the guns come in
            scr_camera_tilt_start(tilt_amplitude, tilt_period, tilt_ramp_frames);

            phase = "attack5";
            attack5_inst = instance_create_depth(0, 0, 0, obj_friend_attack5);
        }
    break;

    case "attack5":
        if (!instance_exists(attack5_inst))
        {
            // camera eases back level once the guns are done, before unflipping
            scr_camera_tilt_stop();

            // re-assert Friend's restored pose, same belt-and-suspenders
            // reasoning as attack6 did for attack2
            if (instance_exists(obj_friend))
            {
                obj_friend.sprite_index = friend_restore_sprite;
                obj_friend.image_index  = 0;
                obj_friend.image_speed  = friend_restore_speed;
            }

            phase = "unflipping";
            scr_screen_flip_to(0, flip_duration);
        }
    break;

    case "unflipping":
        if (!scr_screen_flip_busy())
        {
            if (instance_exists(obj_mewmew))
            {
                obj_mewmew.sprite_index = spr_mewmew_walkup_corrupted;
                obj_mewmew.image_index  = 0;
                obj_mewmew.image_speed  = 0; // static pose, not animating/walking
            }

            phase = "revert";
        }
    break;

    case "revert":
        if (instance_exists(obj_battlebox)) obj_battlebox.target_scale_y = 1;
        if (instance_exists(obj_friend)) { obj_friend.visible = true; }

        instance_destroy();
    break;
}