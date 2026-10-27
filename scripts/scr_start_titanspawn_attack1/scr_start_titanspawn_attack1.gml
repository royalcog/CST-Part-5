function scr_start_titanspawn_attack1()
{
    var _d = instance_exists(obj_battlebox) ? obj_battlebox.depth - 1 : -5001;
    return instance_create_depth(0, 0, _d, obj_titanspawn_attack1);
}

/// moves _a toward _b by at most _amt (Deltarune's scr_approach)
function scr_approach(_a, _b, _amt)
{
    if (_a < _b) return min(_a + _amt, _b);
    return max(_a - _amt, _b);
}