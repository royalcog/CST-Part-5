phase = "dialogue";
timer = 0;

dialogue_started = false;
dialogue_inst = noone;

shake_intensity = 6;
shake_duration = 30;

flip_duration = 40; // frames for the screen to fluidly flip over (and back)

laugh_started = false;

attack2_inst = noone;

// shrink the box down (height only) right away so Friend and the rest of
// the party are a bit more visible below it for the whole attack
box_shrink_scale_y = 0.6;
if (instance_exists(obj_battlebox)) obj_battlebox.target_scale_y = box_shrink_scale_y;

// NOTE: unlike the other Friend attacks, we do NOT hide obj_friend here —
// he needs to stay visible so his laugh (obj_friend_laugh_attack, which
// drives his sprite directly) is actually seen. obj_friend_attack2 still
// hides/restores him itself when it's spawned below, same as always.
//
// The outer fight sequencer hides obj_friend right before it opens the box
// and calls this attack's start_func (same as it does for every attack), so
// we have to explicitly show him again here or he'd stay invisible from the
// very start of this attack, through the dialogue line and the laugh, until
// something else happened to touch .visible.
if (instance_exists(obj_friend)) { obj_friend.visible = true; }

// capture Friend's actual pose going into this attack (whatever the story
// script set beforehand) so we can put him back on exactly that after the
// laugh, instead of guessing/hardcoding a specific sprite
friend_restore_sprite = instance_exists(obj_friend) ? obj_friend.sprite_index : spr_friend_lookdown_animated;
friend_restore_speed  = instance_exists(obj_friend) ? obj_friend.image_speed  : 1;