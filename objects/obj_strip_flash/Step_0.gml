switch (phase)
{
    case "on":
        alpha = 1;
        timer--;
        if (timer <= 0) { phase = "off"; timer = blink_off_time; }
    break;

    case "off":
        alpha = 0;
        timer--;
        if (timer <= 0)
        {
            blink_count++;
            if (blink_count >= blinks) { instance_destroy(); }
            else { phase = "on"; timer = blink_on_time; }
        }
    break;
}