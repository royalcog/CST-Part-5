switch (phase)
{
    case "dialogue":
        if (!dialogue_started)
        {
            dialogue_started = true;
            dialogue_inst = instance_create_depth(0, 0, 0, obj_dialogue_chain);
            dialogue_inst.batches = [
                [ { speaker: obj_friend, text: "Let's try something different.", keep_animating: true } ]
            ];
        }
        else if (!instance_exists(dialogue_inst))
        {
            phase = "waiting_shrink";
        }
    break;

    // make sure the box has fully finished settling into its shrunk height
    // BEFORE the shake/flip starts, so nothing on screen is still drifting
    // into place at the same time the flip happens
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

            phase = "laugh";
        }
    break;

    case "laugh":
        if (!laugh_started)
        {
            laugh_started = true;
            instance_create_depth(0, 0, 0, obj_friend_laugh_attack);
        }
        else if (instance_number(obj_friend_laugh_attack) == 0)
        {
            // obj_friend_laugh_attack drives Friend's sprite directly and
            // never restores it afterward, so he'd otherwise be stuck on
            // the tail end of the laugh animation for the rest of the
            // attack — put him back on whatever pose he actually had going
            // into this attack (captured in Create), not a hardcoded guess
            if (instance_exists(obj_friend))
            {
                obj_friend.sprite_index = friend_restore_sprite;
                obj_friend.image_index  = 0;
                obj_friend.image_speed  = friend_restore_speed;
            }

            // obj_friend_attack2 expects to run against a normal, full-size
            // box (same as every other time it's played) — restore scale
            // before handing off to it so its own box-scale moves (paper's
            // squeeze, rock's shrink) aren't starting from our already-
            // shrunk state
            if (instance_exists(obj_battlebox)) obj_battlebox.target_scale_y = 1;

            phase = "attack2";
            attack2_inst = instance_create_depth(0, 0, 0, obj_friend_attack2);
        }
    break;

    case "attack2":
        if (!instance_exists(attack2_inst))
        {
            // re-assert Friend's restored pose — obj_friend_attack2 only
            // ever touches his .visible, never his sprite, but pinning this
            // again here costs nothing and rules it out as a source of him
            // drifting to some other sprite after the replay
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