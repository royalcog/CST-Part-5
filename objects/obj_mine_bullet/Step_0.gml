if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
if (obj_battlebox.state == "closing") fading = true;
if (fading)
{
    image_alpha -= 0.1;
    if (image_alpha <= 0) instance_destroy();
    exit;
}
t++;
var _spd = lerp(spd0, spd0 * 4, min(1, t / 60));   // x4 over 60 frames  [DR 30]
x += lengthdir_x(_spd, dir);
y += lengthdir_y(_spd, dir);

if (instance_exists(obj_soul))
{
    if (!obj_soul.invulnerable && point_distance(x, y, obj_soul.x, obj_soul.y) <= hit_r)
    {
        scr_soul_take_hit(damage, c_white, c_white);
        instance_destroy();
        exit;
    }
    scr_graze(x, y, hit_r);
}
var _c = scr_box_center();
if (point_distance(x, y, _c.x, _c.y) > 450) instance_destroy();