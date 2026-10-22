if (ghosted)
{
	bob_angle += 0.03; 
	y = start_y + sin(bob_angle) * 5;
}

if sprite_index == spr_ghost_shocked_left && turn_light_change == false
{
	light_offset_x += 20;	
	turn_light_change = true;
}

else if (sprite_index != spr_ghost_shocked_left && sprite_index != spr_ghost_yelling_left && turn_light_change == true)
{
    light_offset_x -= 20;    
    turn_light_change = false;
}

if sprite_index == spr_mewmew_walkup_corrupted && vert_light_change == false
{
	light_offset_x += 7;	
	vert_light_change = true;
}

else if (sprite_index != spr_mewmew_walkup_corrupted && vert_light_change == true)
{
    light_offset_x -= 7;    
    vert_light_change = false;
}


if place_meeting(x, y, obj_wall) == true { yspd = 0; }