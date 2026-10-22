if instance_exists(obj_fade) {
    if (place_meeting(x, y, obj_mewmew) && !obj_fade.fading && obj_fade.fade_alpha == 0) {
        obj_fade.fade_dir = 1;
        obj_fade.fading = true;
        obj_fade.target_rm = target_rm;
        obj_fade.target_x = target_x;
        obj_fade.target_y = target_y;
		obj_fade.target_face = target_face;
		obj_fade.fade_wait_override = fade_wait_override_val;
    }
} else {
    show_debug_message("fade not found!");
}