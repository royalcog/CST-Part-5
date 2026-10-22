depth = -9999;

// Default portrait (or pass this dynamically via your launcher script)
current_portrait = spr_friendmew_questioning;

// Textbox / Dialogue state
lines = [];
line_index = 0;
draw_char = 0;
text_speed = 0.5;

// Enforce GUI size to match room resolution (853x480)
display_set_gui_size(853, 480);