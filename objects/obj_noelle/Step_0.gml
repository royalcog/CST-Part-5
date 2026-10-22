scr_char_jolt_update(id)
if anim_paused_for_talkbox
{
    image_index = anim_pause_frame;
    image_speed = 0;
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

if intro_phase == 2 && music_started && !audio_is_playing(sng_tvmike)
{
    obj_fade.fade_back_in = false;
    obj_fade.fading = true;
    obj_fade.fade_dir = 1;
}

// lock player during intro sequence
if intro_phase == 2
{
    exit;
}

// lock player during cutscene movement
if global.cutscene
{
    if global.move_active && global.move_current_obj == obj_noelle
    {
        if sprite_index != spr_noelle_battle_intro
        {
            sprite_index = spr_noelle_battle_intro;
            image_speed = 1;
            image_index = 0;
        }
    }
    exit;
}

// freeze player during textbox
if instance_exists(obj_textbox)
{
    sprite_index = sprite_override != noone ? sprite_override : sprite[face];
    image_index = 0;
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
if intro_phase == 0
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

// collision
if place_meeting(x + xspd, y, obj_wall) == true { xspd = 0; }
if place_meeting(x, y + yspd, obj_wall) == true { yspd = 0; }
x += xspd;
y += yspd;

// animate only in normal phase
if intro_phase == 0
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

// depth
depth = -bbox_bottom;