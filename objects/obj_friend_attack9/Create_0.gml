phase = "grab";
timer = 0;
depth = -200; // match the box's own layering for the tear visual

hand_left = noone;
hand_right = noone;
hand_fade_speed = 0.04;

shake_intensity = 6;
shake_duration = 30;
shake_timer = 0;

tear_duration = 40; // frames the two halves spend sliding apart
tear_split = 0;

hand_left_start_x = 0;
hand_right_start_x = 0;

tear_sprite = -1;
tear_image_index = 0;
tear_raw_w = 0;
tear_raw_h = 0;
tear_xscale = 1;
tear_yscale = 1;
tear_base_x = 0;
tear_base_y = 0;

dark_fade_duration = 30; // frames to smoothly fade to full black
dark_fade_timer = 0;
dark_fade_start_left = 0;
dark_fade_start_right = 0;

dark_active = false;
prev_darkness_left = 0;
prev_darkness_right = 0;
saved_light_states = [];

// Attack 8's guns+solo-rock combo is swapped out here for a tail + scissors
// combo (no rock, screen stays upright the whole time)
combo_started = false;
tail_inst = noone;
scissors_inst = noone;

total_dark_frames = 900; // ~15s, same pacing as Attack 8's dark window
dark_timer = 0;

if (instance_exists(obj_friend)) { obj_friend.visible = false; }

hand_left  = instance_create_depth(0, 0, -380, obj_rotate_hand, { side: "left"  });
hand_right = instance_create_depth(0, 0, -380, obj_rotate_hand, { side: "right" });

// start invisible so the "grab" phase actually has something to fade from
if (instance_exists(hand_left))  hand_left.image_alpha  = 0;
if (instance_exists(hand_right)) hand_right.image_alpha = 0;