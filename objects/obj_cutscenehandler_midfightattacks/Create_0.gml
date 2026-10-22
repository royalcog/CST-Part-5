display_set_gui_size(camera_get_view_width(view_camera[0]), camera_get_view_height(view_camera[0]));




sprite_queue = [];
after_textbox_queue = [];
after_textbox_delayed_queue = [];
pending_delayed_queue = [];
sprite_queue_delayed = [];
textbox_was_open = false;
after_queue_armed = false;

tenna_attack_state = 0;
tenna_attack_jolted = false;
tenna_midfight_state = 0;
tenna_midfight_delay = 0;
tenna_midfight_jolted = false;
tenna_midfight_last = false;
blackbox_instance = noone;
blackbox_sound = noone;
blackbox_sound_asset = noone;
tenna_battle_intro_state = 0;
tenna_battle_intro_delay = 0;
impact_seq_state = 0;
impact_seq_timer = 0;
cutoff_callback = noone;
villains_ascending = false;
villains_descending = false;
move_queue_active = [];
processing_queue = false;
warp_step = 0;
waiting_for_warp = false;
page_loop_objs = [];
page_move_active = [];

sr_battle_intro_state = 0;
sr_battle_intro_delay = 0;
ralsei_solo_state = 0;
ralsei_solo_delay = 0;

var _keep1 = snd_impact;
var _keep2 = snd_explosion;

movement_queue = [];
current_movement_group_active = false;

// Friend/MewMew Seqence
impact_flash_state = 0;
impact_flash_target = noone;
impact_flash_silhouette_spr = noone;

impact_flash_darken_alpha = 0;
impact_flash_darken_target = 1; // fully black
impact_flash_darken_speed = 0.05;

impact_flash_wait_timer = 0;
impact_flash_wait_duration = 90;

impact_flash_circle_x = 705;
impact_flash_circle_y = 120;
impact_flash_circle_alpha = 0;
impact_flash_circle_speed = 4;
impact_flash_circle_angle = 0;
impact_flash_circle_len = 32; // was 46
impact_flash_circle_wid = 24; // was 20

impact_flash_hit_sprite = noone;    // shocked_backwards, shown on impact
impact_flash_yelling_sprite = noone; // yelling_left, shown during knockback
impact_flash_freeze_timer = 0;
impact_flash_freeze_duration = 8; // frames to hold hit_sprite before knockback starts

impact_flash_knockback_speed = 0;
impact_flash_knockback_dir = 270;
impact_flash_knockback_friction = 0.2;

impact_flash_gerson_obj = noone;
impact_flash_gerson_speed = 0;
impact_flash_gerson_dir = 200;
impact_flash_gerson_friction = 0.3;

impact_flash_next_text_id = noone;
impact_flash_waiting = false;

impact_flash_spawn_obj = noone;
impact_flash_original_sprite = noone;
mewmew_after_impact_inst = noone;
mewmew_before_impact_inst = noone;






