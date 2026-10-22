function scr_get_facing_dir(_inst)
{
    var _name = sprite_get_name(_inst.sprite_index);
    if (string_pos("_left", _name) > 0) return -1;
    if (string_pos("_right", _name) > 0) return 1;
    return 0; // unknown — caller can fall back to random
}