phase = "dialogue";
timer = 0;

dialogue_started = false;
dialogue_inst = noone;

shake_intensity = 6;
shake_duration = 30;

flip_duration = 40; // frames for the screen to fluidly flip over (and back)

attack5_inst = noone;

tilt_amplitude = 8;   // degrees left/right at the peak of the rock
tilt_period = 90;     // frames per full left-right-left cycle
tilt_ramp_frames = 60; // frames to ease into the full swing (~1s)

// shrink the box down (height only) right away so Friend and the rest of
// the party are a bit more visible below it for the whole attack
box_shrink_scale_y = 0.6;
if (instance_exists(obj_battlebox)) obj_battlebox.target_scale_y = box_shrink_scale_y;

// same as attack6: the outer fight sequencer hides obj_friend right before
// opening the box and calling this attack's start_func, so show him again
// here or he'd stay invisible through the dialogue line and the flip
if (instance_exists(obj_friend)) { obj_friend.visible = true; }

// capture Friend's actual pose going into this attack so we can put him
// back on exactly that once we're done with the flip (no laugh this time)
friend_restore_sprite = instance_exists(obj_friend) ? obj_friend.sprite_index : spr_friend_lookdown_animated;
friend_restore_speed  = instance_exists(obj_friend) ? obj_friend.image_speed  : 1;