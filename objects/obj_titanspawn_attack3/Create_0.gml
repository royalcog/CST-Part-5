event_inherited();
// Titan Spawn attack 3: Deltarune's darkshapesfish, with a twist. two fishs slither in sideways while
// small fast copies keep coming. the light burns a fish away from its tail (each piece drops COURAGE), and it
// gets more frantic with every piece it loses, until only its head's left to purify
attack_duration = 720;
spawn_gap       = 40;          // the small copies  [DR every 20]
fish_times = [40, 124];   // [DR at 20 and 62]

/// a small fast copy that faces where it's going and purifies quickly (DR's directed_small)
spawn_shape = function()
{
    var _c    = scr_box_center();
    var _in   = scr_get_box_interior();
    var _half = max(_in.x2 - _in.x1, _in.y2 - _in.y1) / 2;
    var _a    = irandom(360);
    var _dist = _half + spawn_ring_min + irandom(spawn_ring_extra);
    with (instance_create_depth(_c.x + lengthdir_x(_dist, _a), _c.y + lengthdir_y(_dist, _a), depth, obj_darkshape))
    {
        ctrl          = other.id;
        damage        = other.damage;
        dir           = (y >= _c.y) ? 250 - irandom(10) : 110 + irandom(10);
        anim_sprite   = spr_darkshape_directed_small_animated;
        shrink_sprite = spr_darkshape_directed_small;
        light_rate   *= 2.5;   // Deltarune's
        speed_max    *= 1.25;
        face_dir      = true;
    }
}

/// a fish, a bit closer in than the copies, coming in sideways (DR: aimed at the box's middle +-80)
spawn_fish = function()
{
    var _c    = scr_box_center();
    var _in   = scr_get_box_interior();
    var _half = max(_in.x2 - _in.x1, _in.y2 - _in.y1) / 2;
    var _a    = irandom(360);
    var _dist = _half + 45 + irandom(50);
    with (instance_create_depth(_c.x + lengthdir_x(_dist, _a), _c.y + lengthdir_y(_dist, _a), depth, obj_darkshape_fish))
    {
        ctrl    = other.id;
        damage  = other.damage;
        heading = point_direction(x, y, _c.x, _c.y) + choose(-80, 80);
        dir     = heading;
    }
}

// the dashing fish (can't be purified): one every dash_gap frames, on a random row, from a random side
dash_start = 90;    // first one
dash_gap   = 70;    // then one every this many frames...
dash_pair  = 0.25;  // ...and sometimes two at once, on different rows
last_row   = -1;

spawn_dash = function()
{
    var _in  = scr_get_box_interior();
    var _row;
    do { _row = irandom(4); } until (_row != last_row);   // 5 rows, never the same one twice running
    last_row = _row;
    var _y   = lerp(_in.y1 + 16, _in.y2 - 16, _row / 4);
    var _dir = choose(-1, 1);
    with (instance_create_depth(0, 0, depth, obj_dashfish))
    {
        damage = other.damage;
        dir    = _dir;
        y0     = _y;
        var _vx = camera_get_view_x(view_camera[0]), _vw = camera_get_view_width(view_camera[0]);
        hx     = (_dir > 0) ? _vx - 20 : _vx + _vw + 20;   // just off the edge of the screen
    }
}