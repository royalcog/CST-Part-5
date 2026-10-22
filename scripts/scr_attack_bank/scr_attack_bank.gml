function scr_attack_bank(){
	global.atk_sound_of_justice_hammers = scr_make_attack_data(
	    spr_sound_of_justice_idle, spr_sound_of_justice_hammerthrow,
	    10, 8, 0, -60,
	    0, obj_mewmew.damage_color, obj_mewmew.damage_color,
	    scr_spawn_hammer
	);
}