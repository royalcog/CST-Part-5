function scr_get_hit_point(_inst)
{
    var _ox = variable_instance_exists(_inst, "hit_offset_x") ? _inst.hit_offset_x : 0;
    var _oy = variable_instance_exists(_inst, "hit_offset_y") ? _inst.hit_offset_y : 0;
    return { x: _inst.x + (_ox * _inst.image_xscale), y: _inst.y + (_oy * _inst.image_yscale) };
}