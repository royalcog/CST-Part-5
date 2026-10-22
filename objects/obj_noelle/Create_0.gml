xspd = 0;
yspd = 0;
bobbing = false;
move_spd = 2;
sprite[RIGHT] = spr_noelle_right;
sprite[UP] = spr_noelle_up;
sprite[LEFT] = spr_noelle_left;
sprite[DOWN] = spr_noelle_down;
sprite_override = noone;

face = DOWN;

was_moving = false;
was_textbox = false;
global.intro_done = false;
intro_phase = 0;
anim_paused_for_talkbox = false;
anim_pause_frame = 0;

char_id = CharID.Noelle;

if !instance_exists(obj_fade) {
    var _fade = instance_create_layer(0, 0, "Instances", obj_fade);
}
image_xscale = 2;
image_yscale = 2;

start_walking_music();
music_started = false;