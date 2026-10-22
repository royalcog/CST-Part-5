// rm_zero after rm_three, exactly as the fight left it (the room's persistent): King's still down where he knelt.
// Lancer and Queen come up from below, Lancer runs to him, finds out what he did and runs into the castle,
// Queen walks up next to King... and the pie
global.cutscene_lock = true;

// the finale's done: don't let it pick back up
with (obj_knight_finale) instance_destroy();

// --- tuning (all relative to wherever King actually is) ---
lancer_start_dx = -90;           // coming up from below the screen
queen_start_dx  = -170;
arrive_dy       = 30;             // their feet vs. King's when they stop
enter_speed     = 3;
lancer_rush_speed = 3;
lancer_by_king_dx = -70;   lancer_by_king_dy = 0;    // where Lancer stops next to him
door_x = 420;  door_y = 60;       // where Susie and Ralsei went through the door in the finale (just past its bottom)
door_fade_speed = 0.08;           // he fades out there, same rate as them
lancer_run_speed = 5;
queen_walk_speed = 0.8;           // slowly
queen_walk_anim  = 0.7;
queen_by_king_dx = -70;    queen_by_king_dy = 6;     // right next to him
end_sound = snd_damagetaken;
throw_lead_chars = 9;     // she starts throwing this many letters before the end of his last line...
throw_slam_frame = 2;     // ...and it cuts to black on the frame the pie comes down
throw_speed      = 1;     // spr_queen_pie_throw's speed (6fps at 1)

// --- state ---
state = "enter";
st    = 0;

go   = function(_s) { state = _s; st = 0; }
pose = function(_o, _spr, _spd = 0)
{
    if (!instance_exists(_o)) return;
    _o.sprite_index = _spr;
    _o.image_index  = 0;
    _o.image_speed  = _spd;
}
set_feet = function(_o, _x, _y)
{
    var _f = scr_get_feet(_o);
    _o.x += _x - _f.x;
    _o.y += _y - _f.y;
}
/// walks _o's feet toward (_tx,_ty). true once it's there
move_feet = function(_o, _tx, _ty, _spd)
{
    if (!instance_exists(_o)) return true;
    var _f = scr_get_feet(_o);
    if (point_distance(_f.x, _f.y, _tx, _ty) <= _spd) { set_feet(_o, _tx, _ty); return true; }
    var _dir = point_direction(_f.x, _f.y, _tx, _ty);
    _o.x += lengthdir_x(_spd, _dir);
    _o.y += lengthdir_y(_spd, _dir);
    return false;
}

var _bottom = camera_get_view_y(view_camera[0]) + camera_get_view_height(view_camera[0]);

// King, right where he was left
king = instance_exists(obj_king) ? instance_find(obj_king, 0) : noone;
if (king == noone)
{
    king = instance_create_depth(0, 0, -2000, obj_king);   // just in case
    pose(king, spr_king_kneel_sad);
    set_feet(king, 560, 400);
}
var _kf = scr_get_feet(king);
king_x   = _kf.x;
king_y   = _kf.y;
arrive_y = king_y + arrive_dy;

lancer = instance_create_depth(0, 0, -2000, obj_lancer);
pose(lancer, spr_lancer_up);
set_feet(lancer, king_x + lancer_start_dx, _bottom + 60);

queen = instance_create_depth(0, 0, -3001, obj_queen);
pose(queen, spr_queen_walk_up, 1);
set_feet(queen, king_x + queen_start_dx, _bottom + 90);