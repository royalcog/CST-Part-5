if (phase == "travel")
{
    draw_set_alpha(1);
    draw_set_color(bullet_color);
    draw_circle(x, y, bullet_radius, false);

    draw_set_alpha(0.6);
    draw_circle(target_x, target_y, bullet_radius + 4, true);
    draw_set_alpha(1);
}
else if (phase == "blink")
{
    if (blink_visible)
    {
        draw_set_color(c_red);
        draw_circle(x, y, bullet_radius + 2, false);
    }
}

draw_set_color(c_white);