// --- Step Event of obj_dating_overlay ---

// 1. Advance typewriter effect frame-by-frame
if (line_index < array_length(lines))
{
    var _current_line = lines[line_index];
    var _line_length = string_length(_current_line);
    
    if (draw_char < _line_length)
    {
        draw_char += text_speed; // e.g. 0.5 characters per step
    }
}

// 2. Handle Player Input (Press Z or Space to advance)
if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_space))
{
    if (line_index < array_length(lines))
    {
        var _current_line = lines[line_index];
        var _line_length = string_length(_current_line);

        // If line is still typing out, instantly show full line
        if (draw_char < _line_length)
        {
            draw_char = _line_length;
        }
        // If line is finished typing, move to the next dialogue page
        else
        {
            line_index++;
            draw_char = 0; // Reset typewriter counter for next line
        }
    }
    else
    {
        // Reached the end of all lines -> Close overlay
        instance_destroy();
    }
}