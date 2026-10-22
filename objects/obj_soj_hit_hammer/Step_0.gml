// obj_soj_hit_hammer — Step event
timer++;
var _t = clamp(timer / travel_time, 0, 1);
x = lerp(start_x, target_x, _t);
y = lerp(start_y, target_y, _t) - (sin(_t * pi) * arc_height);
image_angle += spin_speed;

if (_t >= 1)
{
    if (instance_exists(obj_sound_of_justice))
    {
        obj_sound_of_justice.sprite_index = spr_sound_of_justice_crumble;
		obj_sound_of_justice.image_index = 0;
		obj_sound_of_justice.image_speed = 1;
		obj_sound_of_justice.freeze_after_this_loop = true;
    }
	if (instance_exists(obj_mewmew))
	{
	    obj_mewmew.sprite_index = spr_ghost_shocked_left; // swap for whichever reaction sprite you want
	    obj_mewmew.image_index = 0;
	}
    audio_play_sound(snd_impact, 5, false);
    instance_destroy();
}