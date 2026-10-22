switch (phase)
{
    case "commence_talk":
        timer++;
        if (timer >= commence_cutoff_frames)
        {
            // cut the line off early — destroy the TALKbox and the chain
            // driving it, regardless of how much of the line has typed
            with (obj_talkbox) instance_destroy();
            if (instance_exists(dialogue_inst)) instance_destroy(dialogue_inst);

            sword_inst = instance_create_depth(0, 0, 0, obj_fist_slam_cutscene);
            sword_inst.target_inst = obj_friend;
            sword_inst.fist_sprite = spr_roaringknight_sword;
            sword_inst.spawn_side  = "left";
            sword_inst.scale       = 3; // scaled up 3x per your ask

            phase = "sword_hit";
        }
    break;

    case "sword_hit":
        if (!instance_exists(sword_inst) || sword_inst.punch_complete)
        {
            // Knight reappears at a clean, known spot just off the LEFT
            // edge of the current view, mirrored to face the right
            // direction now that he's coming in from that side
            if (instance_exists(obj_knight))
            {
                var _vx = camera_get_view_x(view_camera[0]);

                obj_knight.x = _vx - knight_reveal_margin;
                obj_knight.image_xscale *= -1; // mirror so he faces the correct way
                obj_knight.visible = true;
            }

            scr_camera_pan_to(camera_get_view_x(view_camera[0]) - camera_pan_distance, camera_pan_duration);
            phase = "reveal_pan";
        }
    break;

    case "reveal_pan":
        if (!instance_exists(obj_camera_controller) || !obj_camera_controller.panning)
        {
            instance_destroy();
        }
    break;
}