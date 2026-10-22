width = 250;
height = 350;

op_border = 8;
op_space = 16;

pos = 0;

//pause menu
option[0, 0] = "Start Game";
option[0, 1] = "Settings";
option[0, 2] = "Quit Game";

//settings menu
option[1, 0] = "Window Size";
option[1, 1] = "Brightness";
option[1, 2] = "";          // filled in by controls_label()
option[1, 3] = "Back";

// controls: WASD on by default the first time
if (!variable_global_exists("wasd_on")) scr_controls_set(true);

controls_label = function()
{
    option[1, 2] = global.wasd_on ? "Controls: WASD + Arrows" : "Controls: Arrows";
}
controls_label();

op_length = array_length(option);
menu_level = 0;