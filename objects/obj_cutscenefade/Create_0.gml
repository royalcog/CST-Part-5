fade_alpha = 0;
fade_step  = 0.01;       // how much it fades per frame (both ways). bigger = quicker
fade_target = 1;
target_room = room;
has_cleaned_up = false;

fade_color = c_black;         // Can be c_black, c_white, etc.
fade_back_same_room = false;  // Set to true if you want it to fade back in without changing rooms
hold_black = false;
flash_wait_duration = 60;     // How many frames to hold at full color before fading back in (if fade_back_same_room is true)
flash_wait_timer = 0;

wait_timer = 0;
wait_duration = 0;        

new_music_sound = noone;  
new_music_gain = 1;
new_music_fade_time = 1000; 
music_started = false;

old_music_fade_time = 500;  
old_music_faded = false;

music_lead_frames = 0;   
music_lead_timer = 0;

spawn_list = [];
has_spawned = false;

old_music_inst = noone;