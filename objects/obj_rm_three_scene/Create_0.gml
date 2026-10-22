// rm_three: Lancer and Queen in Castle Town. they talk, turn around, the camera rises to the top of town where the
// Titan's tower stands over the fountain with its hand firing, comes back down, and they head off to help
// (fading to rm_zero for the ending)
global.cutscene_lock = true;

lancer = instance_exists(obj_lancer)      ? obj_lancer.id      : noone;
queen  = instance_exists(obj_queen)       ? obj_queen.id       : noone;
town   = instance_exists(obj_castle_town) ? obj_castle_town.id : noone;

// --- tuning (frames) ---
start_wait    = 40;    // after the fade-in, before the first line
turn_wait     = 30;    // after someone turns, before the next thing
pan_up_time   = 180;
pan_hold      = 150;
pan_down_time = 240;
walk_speed    = 2.5;   // them heading off
walk_frames   = 50;    // walking before the fade starts

lancer_talk_sprite = spr_lancer_right_sad;
lancer_turn_sprite = spr_lancer_up;
queen_talk_sprite  = spr_queen_walk_left;
queen_turn_sprite  = spr_queen_walk_up;

// --- the Titan in the distance (spr_castle_town's own pixels for where it goes) ---
mini_src_x     = 770;   // the fountain's column at the top of town
mini_src_base  = 130;   // where the tower comes up from behind the castle
mini_src_hand  = 60;    // the hand's height
mini_w         = 64;    // the tower's width, px
mini_scale     = 0.45;  // the hand
mini_hand_frame = 295;   // the hand holds still on this frame
mini_beam_scale = 0.25;  // the tiny laser's size
mini_laser_end_x = 430;  // where it cuts off: around the other fountain
mini_laser_end_y = -872;
bg_key_threshold = 0.12;   // backdrop pixels darker than this are "behind" the laser; everything else is in front of it
u_bg_key = shader_get_uniform(shd_black_key, "u_threshold");
laser_surf = -1;   // the laser's drawn here first, so the backdrop's linework can be cut out of it

// where the top of town is: the camera never goes above it
var _xs = (town != noone) ? town.image_xscale : 1, _ys = (town != noone) ? town.image_yscale : 1;
town_top    = (town != noone) ? town.y - sprite_get_yoffset(town.sprite_index) * _ys : -992;
var _town_l = (town != noone) ? town.x - sprite_get_xoffset(town.sprite_index) * _xs : 0;
mini_x      = _town_l + mini_src_x * _xs;
mini_base_y = town_top + mini_src_base * _ys;
mini_hand_y = town_top + mini_src_hand * _ys;

// --- state ---
state  = "wait_fade";
st     = 0;
anim_t = 0;
cam_from = 0;
cam_to   = 0;
snd_hum  = -1;

go   = function(_s) { state = _s; st = 0; }
ease = function(_k) { return _k * _k * (3 - 2 * _k); }
pose = function(_o, _spr, _spd = 0)
{
    if (!instance_exists(_o)) return;
    _o.sprite_index = _spr;
    _o.image_index  = 0;
    _o.image_speed  = _spd;
}
get_cam_y = function() { return instance_exists(obj_camera_controller) ? obj_camera_controller.cam_y : camera_get_view_y(view_camera[0]); }
set_cam_y = function(_y)
{
    _y = max(_y, town_top);   // never past the top of town
    if (instance_exists(obj_camera_controller)) obj_camera_controller.cam_y = _y;
    else camera_set_view_pos(view_camera[0], camera_get_view_x(view_camera[0]), _y);
}
cam_home_y = get_cam_y();

pose(lancer, lancer_talk_sprite);
pose(queen,  queen_talk_sprite);