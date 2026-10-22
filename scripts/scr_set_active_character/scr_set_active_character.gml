function scr_set_active_character(_name)
{
    with (obj_battle_ui_box)
    {
        if (char_name == _name)
        {
            obj_UI.active_box = id;
            exit;
        }
    }
}