timer++;

move_dir += spin_speed; // curve the flight path so the burst rotates as it expands

x += lengthdir_x(move_speed, move_dir);
y += lengthdir_y(move_speed, move_dir);

if (instance_exists(obj_soul) && !obj_soul.invulnerable)
{
    if (point_distance(x, y, obj_soul.x, obj_soul.y) <= 12)
    {
        scr_soul_take_hit(0, obj_mewmew.damage_color, obj_mewmew.damage_color);
    }
}

if (timer >= lifespan)
{
    instance_destroy();
}