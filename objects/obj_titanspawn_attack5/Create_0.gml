event_inherited();
// Titan Spawn attack 5: Deltarune's darkshapes in their later forms (pattern_default_speedup_red2/red3).
// copies come much faster, every 3rd spawn is a red shape, and half the copies have changed: EVOLVED ones are
// slower and take longer to purify, DESPERATE ones twitch differently and purify a bit slower
attack_duration = 720;
spawn_gap   = 16;    // [DR every 8]
spawn_scale = 1;
max_shapes  = 20;    // never more copies than this on screen  [DR's cap]

spawn_shape = function()
{
    if (instance_number(obj_darkshape) >= max_shapes) return;
    var _c    = scr_box_center();
    var _in   = scr_get_box_interior();
    var _half = max(_in.x2 - _in.x1, _in.y2 - _in.y1) / 2;
    var _sp   = spawn_pos(_half);
    var _x    = _c.x + lengthdir_x(_sp.dist, _sp.dir), _y = _c.y + lengthdir_y(_sp.dist, _sp.dir);
    spawn_counter++;

    // every 3rd one's a red shape
    if (spawn_counter mod 3 == 2)
    {
        with (instance_create_depth(_x, _y, depth, obj_redshape)) { ctrl = other.id; damage = other.damage; }
        return;
    }
    var _special = (spawn_counter mod 2 == 1) ? choose("evolving", "desperate") : "";
    with (instance_create_depth(_x, _y, depth, obj_darkshape))
    {
        ctrl            = other.id;
        damage          = other.damage;
        dir             = (y >= _c.y) ? 250 - irandom(10) : 110 + irandom(10);
        speed_max      *= 1.1;   // all of them a touch faster  [DR's]
        pushback_radius = 58;
        if (_special == "evolving")
        {
            anim_sprite   = spr_darkshape_evolving_animated;
            shrink_sprite = spr_darkshape_evolving;
            light_rate   *= 0.65;
            speed_max    *= 0.65;
        }
        else if (_special == "desperate")
        {
            anim_sprite   = spr_darkshape_desperate_animated;
            shrink_sprite = spr_darkshape_desperate;
            fastval       = 3;
            light_rate   *= 0.7;
        }
    }
}