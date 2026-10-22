image_xscale = 2;
image_yscale = 2;
depth = -1003;
bob_angle = 0;
start_y = y;
ball_phase = 0;
ball_target_x = 80;   // where the ball stops before turning into the Knight (overridable)
ball_speed = 5;       // px per frame while flying in
anim_loop = true;
shadow_timer = 0;
reverse_phase = 0;
reverse_frame = 0;
exit_dir = -1;        // which way he flies off when turning back into the ball (-1 left, 1 right) — set by scr_knight_fly_in to where he came from
on_exit = undefined;  // optional function, runs once he's fully offscreen
turn_sword_sound_played = false;
hit_offset_x = 58;
hit_offset_y = 30;

char_id = CharID.Knight;

knight_hp = 3000;            // placeholder — tune once the fight's pacing is in
droop_up_stops_audio = true; // the old cutscene cut all sound at droop_up; the battle turns this off

hit_offset_x = 58;
hit_offset_y = 30;
popup_nudge_x = 20; // extra push right for his damage numbers only (doesn't move where attacks land)

// extra TALKbox shift while he's drooped (added on top of offx/offy[CharID.Knight])
talk_nudge_x = 0;
talk_nudge_y = 0;
droop_talk_nudge_x = -40; // negative = left
droop_talk_nudge_y = 25;  // positive = down

shadow_drift_x = 2; // hover-shadow drift direction: positive = right, negative = left