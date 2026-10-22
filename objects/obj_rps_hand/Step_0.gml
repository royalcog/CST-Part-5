if (!variable_instance_exists(id, "side")) side = "left";

depth = -380;

if (chasing)
{
    // draw_angle driven externally during the scissors chase
    image_xscale = lerp(image_xscale, chase_target_scale, 0.08);
    image_yscale = lerp(image_yscale, chase_target_scale, 0.08);
}
else if (bouncing)
{
    bounce_progress += bounce_speed;
    draw_angle = base_angle + sin(bounce_progress) * tilt_amount;
}
else
{
    draw_angle = base_angle;
}