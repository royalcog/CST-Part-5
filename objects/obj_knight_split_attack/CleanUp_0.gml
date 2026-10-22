// glue the box and the soul back together no matter how this ends
if (instance_exists(obj_battlebox))
{
    obj_battlebox.split_axis  = "none";
    obj_battlebox.split_off_a = 0;
    obj_battlebox.split_off_b = 0;
}
if (instance_exists(obj_soul) && obj_soul.split_controlled)
{
    obj_soul.split_controlled = false;
    obj_soul.x = soul_lx;
    obj_soul.y = soul_ly;
}