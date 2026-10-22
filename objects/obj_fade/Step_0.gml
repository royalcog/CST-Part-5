if (fading) {
    fade_alpha += fade_speed * fade_dir;
    fade_alpha = clamp(fade_alpha, 0, 1);

    if (fade_alpha >= 1) 
	{
    fading = false;
    room_goto(target_rm);
    obj_kris.x = target_x;
    obj_kris.y = target_y;
    obj_kris.start_x = target_x;
    obj_kris.start_y = target_y;
    obj_kris.face = target_face;
    if (fade_back_in) 
		{
        fade_dir = -1;
        fading = true;
		}
	}	

    if (fade_alpha <= 0) {
        fading = false;
    }
}