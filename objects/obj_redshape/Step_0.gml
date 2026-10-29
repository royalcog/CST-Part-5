if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
if (obj_battlebox.state == "closing") fading = true;
if (fading)
{
    image_alpha -= 0.1;
    if (image_alpha <= 0) instance_destroy();
    exit;
}

t++;
// fading in: keeps turning to face the SOUL, then locks on and fires
if (t <= appear_time)
{
    image_alpha = t / appear_time;
    if (instance_exists(obj_soul)) dir = point_direction(x, y, obj_soul.x, obj_soul.y);
    exit;
}
spd = min(spd + accel, max_speed);
x += lengthdir_x(spd, dir);
y += lengthdir_y(spd, dir);

if (instance_exists(obj_soul))
{
    if (!obj_soul.invulnerable && point_distance(x, y, obj_soul.x, obj_soul.y) <= hit_radius)
    {
        scr_soul_take_hit(damage, c_white, c_white);
        instance_destroy();
        exit;
    }
    scr_graze(x, y, hit_radius);   // unlike the copies, these give graze TP
}

// gone once it's well past the box
var _c = scr_box_center();
if (point_distance(x, y, _c.x, _c.y) > 400) instance_destroy();