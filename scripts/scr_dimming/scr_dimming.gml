function scr_set_dim_left(_target, _speed = 0.02)
{
    if (instance_exists(obj_lighting))
    {
        obj_lighting.darkness_target_left = _target;
        obj_lighting.darkness_lerp_speed = _speed;
    }
}

function scr_set_dim_right(_target, _speed = 0.02)
{
    if (instance_exists(obj_lighting))
    {
        obj_lighting.darkness_target_right = _target;
        obj_lighting.darkness_lerp_speed = _speed;
    }
}