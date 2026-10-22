image_angle += spin_speed;

if (fading_out)
{
    image_alpha -= fade_speed;
    if (image_alpha <= 0) { instance_destroy(); exit; }
}
else
{
    image_alpha = min(image_alpha + fade_speed, 1);
}

// only dangerous once fully faded in, and never while fading out
if (!fading_out && image_alpha >= 1
 && instance_exists(obj_soul) && !obj_soul.invulnerable
 && point_distance(x, y, obj_soul.x, obj_soul.y) <= hit_radius)
{
    scr_soul_take_hit(damage, c_white, c_white);
}