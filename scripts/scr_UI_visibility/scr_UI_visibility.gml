function scr_ui_show(_reset_sprite = spr_UI_Pink)
{
    if (instance_exists(obj_UI))
    {
        obj_UI.target_x = obj_UI.onscreen_x;
        obj_UI.sprite_index = _reset_sprite;
        obj_UI.image_index = 0;
    }
}

function scr_ui_hide()
{
    if (instance_exists(obj_UI))
    {
        obj_UI.target_x = obj_UI.offscreen_x;
    }
}

function scr_ui_slide_down()
{
    if (instance_exists(obj_UI)) obj_UI.ui_hidden = true;
}

function scr_ui_slide_up()
{
    if (instance_exists(obj_UI)) obj_UI.ui_hidden = false;
}