scr_char_jolt_update(id)
if anim_paused_for_talkbox
{
    image_index = anim_pause_frame;
    image_speed = 0;
}

// handle anim loop regardless of cutscene state
if !anim_loop && image_speed != 0
{
    if image_index >= image_number - 1
    {
        image_speed = 0;
        image_index = image_number - 1;
    }
}

if bobbing
{
    bob_timer++;
    if bob_timer >= bob_speed
    {
        bob_timer = 0;
        bob_index = (bob_index + 1) mod array_length(bob_offsets);
    }
    y = start_y + bob_offsets[bob_index];
}
if variable_instance_exists(id, "shake_base_x")
{
    shake_base_x = x - shake_offset;
}

if (instance_exists(obj_cutscenehandler_midfightattacks))
{
	if obj_cutscenehandler_midfightattacks.tenna_battle_intro_state == 0 && music_started && !audio_is_playing(sng_tvmike)
	{
	    obj_fade.fade_back_in = false;
	    obj_fade.fading = true;
	    obj_fade.fade_dir = 1;
	}
}

// freeze player during textbox, or during the King battle's own dialogue/attack sequencing
if instance_exists(obj_textbox) || instance_exists(obj_king_turn_sequencer)
{
    if anim_loop
    {
        sprite_index = sprite_override != noone ? sprite_override : sprite[face];
        image_index = 0;
    }
    exit;
}

// movement keys
right_key = keyboard_check(vk_right);
left_key = keyboard_check(vk_left);
up_key = keyboard_check(vk_up);
down_key = keyboard_check(vk_down);
xspd = (right_key - left_key) * move_spd;
yspd = (down_key - up_key) * move_spd;
// pause during fade
if instance_exists(obj_fade) && obj_fade.fading
{
    xspd = 0;
    yspd = 0;
}
// set sprite direction
mask_index = sprite[DOWN];
if yspd == 0
{
    if xspd > 0 {face = RIGHT}; 
    if xspd < 0 {face = LEFT}; 
}
if xspd > 0 && face == LEFT {face = RIGHT};
if xspd < 0 && face == RIGHT {face = LEFT};
if xspd == 0
{
    if yspd > 0 {face = DOWN}; 
    if yspd < 0 {face = UP}; 
}
if yspd > 0 && face == UP {face = DOWN};
if yspd < 0 && face == DOWN {face = UP};
// only update sprite when in normal phase
if (instance_exists(obj_cutscenehandler_midfightattacks))
{
	if obj_cutscenehandler_midfightattacks.tenna_battle_intro_state == 0 && !battle_started
	{
	    var _spr = sprite_override != noone ? sprite_override : sprite[face];
	    if sprite_index != _spr
	    {
	        sprite_index = _spr;
	        if xspd != 0 || yspd != 0
	        {
	            image_index = 1;
	        }
	    }
	}
}
// collision
if place_meeting(x + xspd, y, obj_wall) == true { xspd = 0; }
if place_meeting(x, y + yspd, obj_wall) == true { yspd = 0; }
x += xspd;
y += yspd;
// animate only in normal phase
if (instance_exists(obj_cutscenehandler_midfightattacks))
{
	if obj_cutscenehandler_midfightattacks.tenna_battle_intro_state == 0 && !battle_started
	{
	    if xspd == 0 && yspd == 0
	    {
	        image_index = 0;
	        was_moving = false;
	    }
	    else
	    {
	        if !was_moving { image_index = 1; }
	        was_moving = true;
	    }
	}
}
// depth
depth = -bbox_bottom;