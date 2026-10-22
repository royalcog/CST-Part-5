ready = false;
depth = -10000;
//textbox parameters
textbox_width = 650;  
textbox_height = 150; 
border = 25;
textbox_x = camera_get_view_width(view_camera[0])/2 - (textbox_width/2);
textbox_y = camera_get_view_height(view_camera[0]) 
    - (sprite_get_height(spr_textbox) * (textbox_height/sprite_get_height(spr_textbox))) 
    - border + 25;
line_sep = 18;
line_width = textbox_width - border * 3;
txtb_spr[0] = spr_textbox;
txtb_img = 0;
//the text
page = 0;
global.page_number = 0;
text[0] = "";
text_length[0] = string_length(text[0]);
char[0, 0] = "";
char_x[0, 0] = 0;
char_y[0, 0] = 0;
draw_char = 0;
text_speed = 0.5;
text_scale = 2;
page0_applied = false;
hide_box_sprite = false;
center_text = false;
speaker_portrait_spr[0] = noone;      // <-- added
speaker_portrait_frame[0] = 0;        // <-- added
speaker_portrait_animating[0] = false; // <-- added
//secondary (mini, borderless) textbox
secondary_text[0] = "";
secondary_portrait_spr[0] = noone;
secondary_image[0] = 0;
secondary_side[0] = 1;
secondary_col[0] = c_white;
secondary_snd[0] = noone;
secondary_draw_char = 0;
secondary_snd_count = 0;
secondary_snd_delay = 2;
secondary_wait_timer = 0;
secondary_wait_time = 10; // frames to wait before secondary text starts (30 = ~1 sec)
//options
option[0] = "";
option_link_id[0] = -1;
option_pos = 0;
global.option_number = 0;
spr_arrow = spr_textbox_arrow;
setup = false;
//sound
snd_delay = 2;
snd_count = snd_delay;
//effects
scr_set_defaults_for_text();
global.last_free_space = 0;
text_pause_timer = 0;
text_pause_time = 8;
text_speed_override[0] = noone;
// Mewmew stuff
portrait_anim_frame = 0;
portrait_anim_speed = 0.2;
tail_anim_frame = 0;
tail_anim_done = false;
tail_loop_timer = 0;
tail_loop_delay = 120;