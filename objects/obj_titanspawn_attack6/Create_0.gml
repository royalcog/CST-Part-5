event_inherited();
// Titan Spawn attack 6: mines (Deltarune's darkshapesmine). mines home in from outside the box; get too close and
// they stop, flush red, and fire a 5-way spread at you. a few copies keep coming meanwhile
attack_duration = 720;
spawn_gap   = 60;     // the copies, slow
spawn_scale = 1;
mine_start  = 30;
mine_gap    = 75;     // a mine every this many frames...
mine_max    = 3;      // ...up to this many at once

spawn_mine = function()
{
    if (instance_number(obj_darkshape_mine) >= mine_max) return;
    var _c    = scr_box_center();
    var _in   = scr_get_box_interior();
    var _half = max(_in.x2 - _in.x1, _in.y2 - _in.y1) / 2;
    var _sp   = spawn_pos(_half);
    with (instance_create_depth(_c.x + lengthdir_x(_sp.dist, _sp.dir), _c.y + lengthdir_y(_sp.dist, _sp.dir), depth, obj_darkshape_mine))
    {
        ctrl   = other.id;
        damage = other.damage;
    }
}