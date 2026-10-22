// In obj_datingsim_UI's Draw GUI Event:

// 1. Draw Background Overlay
if (sprite_exists(spr_datingsim_inverted)) 
{
    draw_sprite_stretched(spr_datingsim_inverted, 0, 0, 0, display_get_gui_width(), display_get_gui_height());
}

// 2. Draw Stacked UI Frames
if (sprite_exists(spr_datingsim_UI)) 
{
    var _frame_count = sprite_get_number(spr_datingsim_UI);
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    for (var i = 0; i < _frame_count; i++) 
    {
        draw_sprite_stretched(spr_datingsim_UI, i, 0, 0, _gw, _gh);
    }
}
// 3. Draw Character Portrait ON TOP

if (sprite_exists(portrait)) 
{
    draw_sprite_ext(portrait, 0, display_get_gui_width() / 2 - 100, display_get_gui_height() / 2 - 175, 2, 2, 0, c_white,  1);
}