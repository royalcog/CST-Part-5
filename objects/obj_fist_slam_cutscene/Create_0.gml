depth = -99999;
target_inst = noone;

fist_sprite = spr_friend_hand_rock;
spawn_side = "right"; // "right" = old Knight-punch behavior; "left" mirrors it for the Friend hit
scale = 1;            // uniform scale multiplier on top of the facing-direction flip

phase = "darken";

darken_alpha = 0;
darken_speed = 0.08;

fist_room_x = 0;
fist_room_y = 0;
fist_start_x = 0;
fist_slow_x = 0;
fist_y_offset = 40; // how much lower than the knight it flies in at — tune to taste

hit_offset = 200; // triggers this many pixels before reaching the knight's exact origin — tune to taste

fast_speed = 24;
slow_speed = 5;

spawn_margin = 60;

knockback_speed = 0;
knockback_max = 18;
knockback_dir = 0;
knockback_friction = 0.3;

offscreen_timer = 0;
offscreen_wait = 60; // ~1 second at 60fps
explosion_played = false;

bob_enabled = true; // toggle this off externally when you want the hand still (e.g. mid-attack)
bob_amount = 4;      // pixels of vertical travel — keep small per your "not too much"
bob_speed = 0.04;    // how fast it oscillates
bob_timer = 0;
fist_base_y = 0;     // the resting y it bobs around — set once, when it settles into "hold"

punch_complete = false; // the fight sequencer watches this to know when it can move on

alpha = 1; // used by the split_fade phase; normal punch always draws at full alpha