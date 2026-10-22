function scr_gerson_lantern_on()
{
    if (instance_exists(obj_gerson))
    {
        obj_gerson.sprite_index = spr_gerson_hammer_idle_lantern_left; // placeholder — swap in your real asset name once made
        obj_gerson.image_index = 0;
        obj_gerson.light_on = true; // this is what makes obj_lighting's loop start treating him as a light source
    }
}