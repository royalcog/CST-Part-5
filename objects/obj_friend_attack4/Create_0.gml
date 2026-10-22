timer = 0;

// optional overrides — used when this same pendulum is reused as a bigger,
// stacked sub-attack elsewhere (see obj_friend_attack9); left alone, this
// object behaves exactly like the standalone Attack 4 always has
if (!variable_instance_exists(id, "scale_override")) scale_override = -1;
if (!variable_instance_exists(id, "duration_override")) duration_override = -1;
if (!variable_instance_exists(id, "pivot_at_screen_center")) pivot_at_screen_center = false;

// pendulum motion: oscillates smoothly around "straight down" (our own
// angle convention: 0 = down, 90 = right, 180 = up, 270 = left — matches
// GameMaker's image_angle direction), swinging out toward horizontal on
// each side and back, like a real pendulum, for as long as this attack lasts
swing_amplitude = 90;    // how far it swings to each side (90 = fully horizontal)
swing_period = 150;      // frames for one full left-right-left cycle
pendulum_duration = (duration_override > 0) ? duration_override : 600; // total frames this attack lasts before ending

angle = 0; // starts hanging straight down, at rest
prev_angle = 0;
swing_direction = 0; // tracks whether it's currently swinging toward +angle or -angle

sprite_index = spr_friend_tail;
image_speed = 0;
depth = -370;

tail_scale = (scale_override > 0) ? scale_override : 9; // much bigger, per request
tail_raw_width = sprite_get_width(sprite_index);
tail_raw_height = sprite_get_height(sprite_index);
tail_length = tail_raw_height * tail_scale;
tail_half_width = (tail_raw_width * tail_scale) / 2;

pivot_x = x;
pivot_y = y;
if (pivot_at_screen_center)
{
    // hangs from the top-center of the actual view instead of the box, so
    // its swing sweeps corner-to-corner across the whole screen
    pivot_x = camera_get_view_x(view_camera[0]) + camera_get_view_width(view_camera[0]) / 2;
    pivot_y = camera_get_view_y(view_camera[0]) - 20;
    x = pivot_x;
    y = pivot_y;
}
else if (instance_exists(obj_battlebox))
{
    var _interior = scr_get_box_interior();
    pivot_x = lerp(_interior.x1, _interior.x2, 0.5);
    pivot_y = _interior.y1 - 20; // nudged up a bit from the box's top edge
    x = pivot_x;
    y = pivot_y;
}

color_blue = c_aqua;
color_orange = c_orange;
color_mode = choose("blue", "orange");

// offscreen buffer used to recolor the tail sprite in real time (see
// Draw event) — sized generously around the pivot so the fully-extended,
// scaled-up tail always fits inside it regardless of swing angle
tail_surf = -1;
tail_surf_size = (tail_length + tail_half_width) * 2 + 40;

if (instance_exists(obj_friend)) { obj_friend.visible = false; }