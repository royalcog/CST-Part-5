if sprite_index == spr_gersonsittinglaughing
{
    sprite_offset_x = 10; // adjust to taste
    sprite_offset_y = -10; // adjust to taste
}
else if sprite_index == spr_gersonwritingscratchloop || sprite_index == spr_gersonwritingscratchaha
	|| sprite_index == spr_gersonshakinghead
{
	sprite_offset_x = 4; // adjust to taste
    sprite_offset_y = -7; // adjust to taste
}
else
{
    sprite_offset_x = 0;
    sprite_offset_y = 0;
}

if (sprite_index == spr_gerson_hammer_laugh_lantern_left) && laugh_light_change == false
{
    light_offset_x -= 6;
    light_offset_y -= 5;
	laugh_light_change = true;
}
else if (sprite_index != spr_gerson_hammer_laugh_lantern_left) && laugh_light_change == true
{
	light_offset_x += 6;
    light_offset_y += 5;	
	laugh_light_change = false;
}

if (sprite_index == spr_gerson_hammer_idle_lantern_left || sprite_index == spr_gerson_hammer_idle_lantern_back_left) && turn_light_change == false
{
	light_offset_x -= 50;	
	turn_light_change = true;
}
else if (sprite_index != spr_gerson_hammer_idle_lantern_left && sprite_index != spr_gerson_hammer_idle_lantern_back_left) && turn_light_change == true
{
	light_offset_x += 50;	
	turn_light_change = false;
}