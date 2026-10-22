function scr_doki_bar_show(_reset_sprite = spr_doki_bar_int)
{
    if (!instance_exists(obj_bar_int))
    {
        var bar = instance_create_layer(0, 0, "Instances", obj_bar_int);
        bar.target_x = bar.onscreen_x;
        bar.sprite_index = _reset_sprite;
        bar.image_index = 0;
    }
}


function scr_doki_bar_hide()
{
    if (instance_exists(obj_bar_int))
    {
        obj_bar_int.target_x = obj_bar_int.offscreen_x;
    }
}