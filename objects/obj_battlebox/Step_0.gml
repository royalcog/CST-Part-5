if (target_scale_x != prev_target_scale_x || target_scale_y != prev_target_scale_y)
{
    audio_play_sound(snd_impact, 5, false);
    prev_target_scale_x = target_scale_x;
    prev_target_scale_y = target_scale_y;
}

image_xscale = lerp(image_xscale, target_scale_x, scale_speed);
image_yscale = lerp(image_yscale, target_scale_y, scale_speed);

x = box_base_x + (raw_width  - raw_width  * image_xscale) / 2;
y = box_base_y + (raw_height - raw_height * image_yscale) / 2;

switch (state)
{
    case "rising":
	    image_index += rise_speed;
	    if (image_index >= image_number - 1)
	    {
	        image_index = image_number - 1;
	        state = "idle";

	        if (!on_open_callback_done)
	        {
	            on_open_callback_done = true;
	            var _soul = instance_create_depth(x + raw_width/2, y + raw_height/2, depth - 2, obj_soul);
	        }
	    }
	break;

    case "idle":
    break;

    case "closing":
        image_index -= rise_speed
        if (image_index <= 0)
        {
            image_index = 0;
            state = "done";
            instance_destroy();
        }
    break;
}