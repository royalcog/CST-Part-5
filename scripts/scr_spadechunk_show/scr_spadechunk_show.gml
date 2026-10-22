function scr_spadechunk_show(_reset_sprite = spr_spadechunk)
{
    if (!instance_exists(obj_spadechunk))
    {
        var spade = instance_create_layer(0, 0, "Instances", obj_spadechunk);
        spade.target_x = spade.onscreen_x;
        spade.sprite_index = _reset_sprite;
        spade.image_index = 0;
    }
}


function scr_spadechunk_hide()
{
    if (instance_exists(obj_spadechunk))
    {
        obj_spadechunk.target_x = obj_spadechunk.offscreen_x;
    }
}