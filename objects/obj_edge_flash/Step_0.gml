switch (phase)
{
    case "in":
        alpha += fade_speed;
        if (alpha >= 0.6) { alpha = 0.6; phase = "hold"; }
    break;
    case "hold":
        hold_timer--;
        if (hold_timer <= 0) { phase = "out"; }
    break;
    case "out":
        alpha -= fade_speed;
        if (alpha <= 0) { instance_destroy(); }
    break;
}