switch (phase)
{
    case "in":
        alpha += fade_speed;
        if (alpha >= 0.4) { alpha = 0.4; phase = "hold"; }
    break;
    case "hold":
        alpha -= fade_speed;
        if (alpha <= 0) { instance_destroy(); }
    break;
}