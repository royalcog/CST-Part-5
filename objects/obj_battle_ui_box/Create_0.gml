char_name = "";
hp = 0;
max_hp = 1;
box_offset_x = 0;
box_offset_y = 0;
sprite_frame = spr_queenbox_empty;
hurt_frame = spr_queenbox_hurtempty;
attack_frame = spr_queenbox_attack_empty; // shown instead of sprite_frame once selected_attack is true
selected_attack = false; // true once this character has locked in an attack for the current round
frame_scale = 1;
bar_offset_x = 0;
bar_offset_y = 0;
bar_width = 80;
bar_height = 6;
bar_fill_color = c_white;
hp_current_x = 0;
hp_max_x = 0;
hp_text_offset_y = 0;
hurt_flash_time = 20;

hurt_timer = 0;
hp_display = hp;
hp_digit_w = 8;   // each digit's rendered ink width, in native px
hp_digit_h = 12;  // each digit's rendered ink height, in native px
hp_digit_gap = 2; // px of space between one digit and the next
hp_digit_y_offset = -3; // nudge the whole HP number up/down, in final screen px (independent of each box's frame_scale)

// fnt_determination's own baked digit ink size (native px) — the reference
// size scr_draw_pixel_number scales from to hit hp_digit_w x hp_digit_h
hp_font = fnt_determination;
hp_font_native_w = 6;
hp_font_native_h = 9;

divider_y = 156;
inactive_rest_offset = 25;
icon_rect_x = 0; icon_rect_y = 0; icon_rect_w = 0; icon_rect_h = 0; // where the face sits within the box art (native px)
hurt_icon_scale = 1; // shrink the hurt face relative to the normal one — 1 = same size, 0.8 = 20% smaller
active_raise_offset = 8; // how far up the active box lifts compared to resting position

// character hurt pose (the actual Susie/Ralsei/Queen object, not the box art)
body = noone;
body_hurt_sprite = -1;
body_down_sprite = -1; // swooned pose when HP drops to 0 or below
body_idle_sprite = -1; // what they go back to when they revive
body_inst = noone;
body_saved = undefined;
body_hurt_time = 30;    // how long the hurt pose holds
body_hurt_timer = 0;
body_shake_amount = 4;  // px, fades to 0 over the hurt time

// stretch mode: clones the box's end borders out to the screen edges and fills the gap
// with a plain interior column, so the panel spans the whole screen while the actual
// box art stays where it is. Column numbers are for spr_ralseibox_empty's art.
stretch_to_screen = false;
stretch_cap_l_x  = 1;   // left border starts at this source column
stretch_cap_r_x  = 845; // right border starts at this source column
stretch_cap_w    = 8;   // border width, in source px
stretch_fill_col = 20;  // a plain interior column (border lines top/bottom, black middle)