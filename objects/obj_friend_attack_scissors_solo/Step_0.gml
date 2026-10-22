timer++;

// sample the soul's position periodically to build a trailing path
if (instance_exists(obj_soul))
{
    trail_sample_timer--;
    if (trail_sample_timer <= 0)
    {
        array_push(trail_points, { x: obj_soul.x, y: obj_soul.y });
        if (array_length(trail_points) > trail_max_points) array_delete(trail_points, 0, 1);
        trail_sample_timer = trail_sample_interval;
    }
}

if (instance_exists(chase_hand) && instance_exists(obj_soul))
{
    // follow the recorded trail toward the soul instead of beelining
    // straight at its current (live) position
    var _follow_x = obj_soul.x;
    var _follow_y = obj_soul.y;
    if (array_length(trail_points) > 0)
    {
        var _lead = trail_points[0];
        _follow_x = _lead.x;
        _follow_y = _lead.y;

        if (point_distance(chase_hand.x, chase_hand.y, _follow_x, _follow_y) < 12)
        {
            array_delete(trail_points, 0, 1);
        }
    }

    with (chase_hand)
    {
        var _dir = point_direction(x, y, _follow_x, _follow_y);
        x += lengthdir_x(other.chase_speed, _dir);
        y += lengthdir_y(other.chase_speed, _dir);
        draw_angle = _dir;

        if (scr_attack_touches_soul())
        {
            scr_soul_take_hit(0, obj_mewmew.damage_color, obj_mewmew.damage_color);
        }
    }
}

sub_timer--;
if (!awaiting_punch && sub_timer <= 0 && instance_number(obj_friend_hand_punch) == 0)
{
    var _bounds = scr_get_attack_bounds();
    var _orientation = choose("vertical", "horizontal");
    var _frac = random_range(0.1, 0.9);
    var _side_pool = (_orientation == "vertical") ? ["up", "down"] : ["left", "right"];
    var _side = _side_pool[irandom(1)];
    var _perp = (_orientation == "vertical")
        ? lerp(_bounds.x1, _bounds.x2, _frac)
        : lerp(_bounds.y1, _bounds.y2, _frac);

    // telegraph where the punch is about to come through, before it fires
    instance_create_depth(0, 0, -390, obj_strip_flash, { orientation: _orientation, position_frac: _frac, blinks: 2 });

    punch_telegraph_side = _side;
    punch_telegraph_perp = _perp;
    awaiting_punch = true;
}

if (awaiting_punch && instance_number(obj_strip_flash) == 0)
{
    instance_create_depth(0, 0, -380, obj_friend_hand_punch, { side: punch_telegraph_side, fixed_coord: punch_telegraph_perp });

    awaiting_punch = false;
    sub_timer = 45;
}

if (timer >= duration)
{
    instance_destroy();
}