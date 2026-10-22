/// switches WASD on/off as movement keys (the arrow keys always work)
function scr_controls_set(_wasd)
{
    global.wasd_on = _wasd;
    keyboard_unset_map(); // clear any old mapping first
    if (_wasd)
    {
        keyboard_set_map(ord("W"), vk_up);
        keyboard_set_map(ord("A"), vk_left);
        keyboard_set_map(ord("S"), vk_down);
        keyboard_set_map(ord("D"), vk_right);
    }
}

/// flips between the two
function scr_controls_toggle()
{
    scr_controls_set(!global.wasd_on);
}