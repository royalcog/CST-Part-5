phase = "start";
timer = 0;

left_hand = noone;
right_hand = noone;

beat = 0; 
beat_length = 30;
chant_text = "";

match_result = "";
winner_side = ""; 

sub_phase = "";
sub_timer = 0;
punch_repeats = 0;
max_punch_repeats = 0;
punch_side = "left";
chase_hand = noone;
chase_speed = 2.5;

trail_points = [];
trail_sample_timer = 0;
trail_sample_interval = 8;
trail_max_points = 12;

awaiting_punch = false;
punch_telegraph_side = "left";
punch_telegraph_perp = 0;

// rock: which rows the left/right pincer hands punch through
rock_left_frac = 0.5;
rock_right_frac = 0.5;

// which shape each hand actually picked, revealed the instant SHOOT hits
reveal_left_choice = "";
reveal_right_choice = "";

if (instance_exists(obj_friend)) { obj_friend.visible = false; }