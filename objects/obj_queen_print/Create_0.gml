print_spr = spr_lancer_dialogue;
print_index = 1;
print_width = sprite_get_width(print_spr);
print_height = sprite_get_height(print_spr);

mouth_offset_x = -4;
mouth_offset_y = -94;

x = obj_queen.x + mouth_offset_x;
y = obj_queen.y + mouth_offset_y;

squish_x_scale = 0.15; // thin while printing
full_x_scale = 1;      // smaller overall than before (was 2)
x_scale = squish_x_scale;
y_scale = 1;            // smaller overall than before (was 2)

reveal_height = 0;
reveal_timer = 0;
reveal_length = 90; // slower reveal (was 40)

pop_timer = 0;
pop_length = 16; // slower pop (was 8)

phase = "printing";

light_on = true;
light_radius = 90;
light_strength = 0.6;
light_offset_x = 0;
light_offset_y = (print_height * y_scale) / 2;

post_wait_time = 20; // frames to hold after printing finishes, before flying off
post_wait_timer = 0;

fly_speed = 0.08; // lerp rate — lower is slower/floatier

var _cam = scr_get_gui_scale();
fly_target_x = _cam.vx - 100; // just past the camera's left edge

print_snd_played = false;