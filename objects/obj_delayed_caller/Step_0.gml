switch (mode)
{
    case "immediate":
        frames_left--;
        if (frames_left <= 0)
        {
            if (call_func != noone) call_func();
            instance_destroy();
        }
    break;

    case "on_page":
        if (instance_exists(obj_textbox) && obj_textbox.page == target_page)
        {
            frames_left--;
            if (frames_left <= 0)
            {
                if (call_func != noone) call_func();
                instance_destroy();
            }
        }
        else if (!instance_exists(obj_textbox))
        {
            instance_destroy(); // textbox closed before this page's timer finished — just cancel
        }
    break;

    case "after_textbox":
        if (!started)
        {
            if (!instance_exists(obj_textbox))
            {
                started = true; // textbox just closed — start counting now
            }
        }
        else
        {
            frames_left--;
            if (frames_left <= 0)
            {
                if (call_func != noone) call_func();
                instance_destroy();
            }
        }
    break;
	
	case "on_frame":
        if (!instance_exists(target) || target.sprite_index != target_sprite)
        {
            instance_destroy(); // sprite changed or object gone — cancel
            break;
        }
        if (floor(target.image_index) >= target_frame)
        {
            if (call_func != noone) call_func();
            instance_destroy();
        }
    break;
}