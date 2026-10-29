function scr_start_titanspawn_attack5()
{
    var _d = instance_exists(obj_battlebox) ? obj_battlebox.depth - 1 : -5001;
    return instance_create_depth(0, 0, _d, obj_titanspawn_attack5);
}