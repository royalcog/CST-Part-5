// 1. Darkened Fullscreen Background
draw_set_color(c_black);
draw_rectangle(0, 0, 853, 480, false);

if (sprite_exists(spr_datingsim_inverted))
{
    draw_sprite_stretched(spr_datingsim_inverted, 0, 0, 0, 853, 480);
}

// 2. Character Portrait (Centered & Scaled by Multiplier)
// --- Draw GUI Event of obj_dating_overlay ---

// Red background test box to verify GUI bounds
draw_set_color(c_red);
draw_rectangle(0, 0, 853, 480, false); 

if (sprite_exists(current_portrait))
{
    // Force 3x scaling right in the middle of 853x480 screen
    draw_sprite_ext(
        current_portrait, 
        0, 
        426, 
        200, 
        3, 
        3, 
        0, 
        c_white, 
        1
    );
}

// 3. Dating Sim UI Box Overlay (Drawn on top of portrait)
if (sprite_exists(spr_datingsim_UI))
{
    var _frame_count = sprite_get_number(spr_datingsim_UI);
    for (var i = 0; i < _frame_count; i++)
    {
        draw_sprite_stretched(spr_datingsim_UI, i, 0, 0, 853, 480);
    }
}

// 4. Typewriter Dialogue Text
if (line_index < array_length(lines))
{
    draw_set_font(fnt_determination);
    draw_set_color(c_white);
    draw_set_halign(fa_center);

    var _shown = string_copy(lines[line_index], 1, floor(draw_char));
    draw_text(853 / 2, 480 / 2 + 140, _shown);

    draw_set_halign(fa_left); // Reset alignment
}