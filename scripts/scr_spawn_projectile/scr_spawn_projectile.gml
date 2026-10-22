function scr_spawn_projectile(_proj_obj, _start_x, _start_y, _damage_amount = 0, _color_top = c_white, _color_bottom = c_white, _overrides = undefined)
{
    var _target = scr_pick_target_soul_or_random();
    if (_target == noone)
    {
        _target = { x: _start_x, y: _start_y }; // nothing to aim at — just use its own spawn point
    }

    var _p = instance_create_depth(_start_x, _start_y, -150, _proj_obj);
    _p.start_x = _start_x;
    _p.start_y = _start_y;
    _p.target_x = _target.x;
    _p.target_y = _target.y;
    _p.damage_amount = _damage_amount;
    _p.color_top = _color_top;
    _p.color_bottom = _color_bottom;

    if (!is_undefined(_overrides))
    {
        var _names = variable_struct_get_names(_overrides);
        for (var i = 0; i < array_length(_names); i++)
        {
            variable_instance_set(_p, _names[i], variable_struct_get(_overrides, _names[i]));
        }
    }

    return _p;
}