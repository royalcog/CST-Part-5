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