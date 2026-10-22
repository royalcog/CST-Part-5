switch (phase)
{
    case "fading_in":
        alpha += fade_in_speed;
        if (alpha >= max_alpha)
        {
            alpha = max_alpha;
            phase = "holding";
        }
    break;

    case "holding":
        hold_timer--;
        if (hold_timer <= 0) phase = "fading_out";
    break;

    case "fading_out":
        alpha -= fade_out_speed;
        if (alpha <= 0) instance_destroy();
    break;
}