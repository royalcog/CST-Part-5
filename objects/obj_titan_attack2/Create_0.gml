event_inherited();
// the Titan's attack 2: Titan Spawn attack 3 (the copies + the fish the light burns away), but instead of the dashing
// fish coming across sideways, King's spade bombs erupt from the sides of the screen and fly into the box (each
// lands, flashes, and bursts into a ring of spades like his Chapter 1 attack). same length as attack 3.
// made by scr_start_titan_attack2 (scr_titan_battle)

dash_start = 999999;   // (no dashing fish this time)

// --- tuning: the bombs ---
bomb_start     = 90;    // frames into the attack before the first one
bomb_gap       = 70;    // then one every this many frames...
bomb_pair      = 0.25;  // ...and sometimes two at once (one from each side)
bomb_stop      = 170;   // no new ones in the last this-many frames (so they burst before the box closes)
bomb_fuse      = 60;    // frames on the ground before it bursts
bomb_toss_time = 45;    // frames from the side of the screen into the box
bomb_arc       = 60;    // how high it arcs on the way
bomb_erupt     = 12;    // frames it takes to pop out to full size at the edge of the screen
bomb_damage    = 50;    // (the bomb itself and its ring of spades)
bomb_edge      = 16;    // px in from the edge of the screen it erupts
land_margin    = 28;    // lands at least this far from the box's walls
bomb_spacing   = 40;    // ...and this far from any other bomb
bomb_sound_gain = 0.4;  // the throw sound (once per throw, even when two come at once)

with (obj_box_bullet_drawer) instance_destroy();   // (the ring spades get drawn clipped to the box by this)
instance_create_depth(0, 0, instance_exists(obj_battlebox) ? obj_battlebox.depth - 1 : depth, obj_box_bullet_drawer);

/// a bomb erupts at the side of the screen (_side -1 left, 1 right) and flies into the box
spawn_bomb = function(_side)
{
    var _in = scr_get_box_interior();
    var _lx, _ly;
    for (var _try = 0; _try < 12; _try++)   // a landing spot that isn't crowding another bomb
    {
        _lx = random_range(_in.x1 + land_margin, _in.x2 - land_margin);
        _ly = random_range(_in.y1 + land_margin, _in.y2 - land_margin);
        var _clear = true;
        with (obj_spade_bomb) if (point_distance(land_x, land_y, _lx, _ly) < other.bomb_spacing) { _clear = false; break; }
        if (_clear) break;
    }

    var _vx = camera_get_view_x(view_camera[0]), _vw = camera_get_view_width(view_camera[0]);
    var _sx = (_side < 0) ? _vx + bomb_edge : _vx + _vw - bomb_edge;
    var _sy = random_range(_in.y1, _in.y2);

    var _b = instance_create_depth(_sx, _sy, obj_battlebox.depth - 1, obj_spade_bomb);
    _b.start_x      = _sx;
    _b.start_y      = _sy;
    _b.land_x       = _lx;
    _b.land_y       = _ly;
    _b.fuse_frames  = bomb_fuse;
    _b.toss_frames  = bomb_toss_time;
    _b.arc_height   = bomb_arc;
    _b.erupt_frames = bomb_erupt;
    _b.bomb_damage  = bomb_damage;
    _b.ring_damage  = bomb_damage;
    _b.flash_timer  = 6;   // a white pop as it erupts
}