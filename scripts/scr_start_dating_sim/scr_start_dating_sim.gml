function scr_start_dating_sim(_portrait, _lines)
{
    var _inst = instance_create_depth(0, 0, -9999, obj_dating_overlay);

    _inst.current_portrait = _portrait;
    _inst.lines = _lines;

    return _inst;
}