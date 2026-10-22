// --- tuning ---
box_scale       = 0.6;   // box shrinks to this first so it has room to bounce around
bottom_reserve  = 95;    // bottom wall sits this far above the screen bottom (keeps the box off the HP boxes)
vis_pad_x       = 16;    // spr_battlebox's transparent side padding (x 0-15 / 316-331) — bounce off the visible edge

spade_reach     = 0.5;   // how far into the box each spade's CENTER sits when the box is against that wall
spade_size      = 36;    // spr_spade width
spade_gap       = 8;     // space between neighbouring spades
spade_spin_min  = 0.5;   // deg/frame, each spade picks its own speed + direction
spade_spin_max  = 3;
spade_damage    = 36;
spade_hit_radius = 12;

speed_start       = 1.5;  // box speed at the start of the bounce
speed_max         = 3.5;  // top speed — same cap as before, it just gets there sooner
speed_ramp_frames = 420;  // frames to reach top speed (~7s); lower = speeds up quicker
bounce_duration   = 840;  // frames of bouncing (~14s)
warmup_frames   = 45;    // spades fade in, box holds still
angle_jitter    = 10;    // +/- degrees off a perfect 45 so it doesn't feel robotic
bounce_sound    = snd_impact; // plays on every wall hit, -1 for none

// --- screen walls ---
var _cam = view_camera[0];
wall_l = camera_get_view_x(_cam);
wall_t = camera_get_view_y(_cam);
wall_r = wall_l + camera_get_view_width(_cam);
wall_b = wall_t + camera_get_view_height(_cam) - bottom_reserve;

// where the box sits so it's dead-center of the bounce area (and the spade frame)
center_base_x = (wall_l + wall_r) / 2 - obj_battlebox.raw_width  / 2;
center_base_y = (wall_t + wall_b) / 2 - obj_battlebox.raw_height / 2;

// --- state ---
start_base_x = obj_battlebox.box_base_x;
start_base_y = obj_battlebox.box_base_y;
move_dir = choose(45, 135, 225, 315) + random_range(-angle_jitter, angle_jitter);
move_speed = speed_start;
timer = 0;
state = "shrink";

obj_battlebox.target_scale_x = box_scale;
obj_battlebox.target_scale_y = box_scale;

spawn_spade = function(_x, _y)
{
    var _s = instance_create_depth(_x, _y, obj_battlebox.depth - 1, obj_spade_border);
    _s.image_angle = random(360);
    _s.spin_speed  = random_range(spade_spin_min, spade_spin_max) * choose(-1, 1);
    _s.damage      = spade_damage;
    _s.hit_radius  = spade_hit_radius;
};