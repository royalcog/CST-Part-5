if (instance_exists(obj_battlebox))
{
    // stay clamped to the midpoint of the box's left/right edge, in the
    // box's own rotating frame, so the hand visibly stays gripping the
    // side as the box spins
    var _interior = scr_get_box_interior();
    var _cy = lerp(_interior.y1, _interior.y2, 0.5);
    var _local_x = (side == "left") ? _interior.x1 : _interior.x2;

    var _world = scr_box_local_to_world(_local_x, _cy);
    x = _world.x;
    y = _world.y;

    image_angle = obj_battlebox.box_angle;
    draw_angle = image_angle;
}

// optional extra jitter — set by whatever's currently shaking the box
// (e.g. obj_friend_attack8/9 during their "shake" phase) so the hands
// visibly rattle in place instead of relying on the camera shake alone
if (shake_jitter_amount > 0)
{
    x += random_range(-shake_jitter_amount, shake_jitter_amount);
    y += random_range(-shake_jitter_amount, shake_jitter_amount);
}