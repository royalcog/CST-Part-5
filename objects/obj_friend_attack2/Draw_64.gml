// Scissors: broken dotted trail showing the path the scissors are
// catching up along, rather than a straight line to the soul
if (phase == "attack_scissors" && sub_phase == "chase_and_punch" && array_length(trail_points) > 0)
{
    draw_set_color(c_white);
    draw_set_alpha(0.5);
    for (var _i = 0; _i < array_length(trail_points); _i++)
    {
        var _pt = trail_points[_i];
        var _p = scr_room_to_gui(_pt.x, _pt.y);
        draw_circle(_p.x, _p.y, 3, false);
    }
    draw_set_alpha(1);
}

// Draw the chant text
if (chant_text != "")
{
    draw_set_font(fnt_greaterdetermination); // Replace with your font
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    
    // Draw in the middle of the screen (assuming standard 640x480 Undertale resolution)
    // Change these coordinates if your room size is different!
    draw_text(426, 100, chant_text);
    
    // Reset alignment
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}