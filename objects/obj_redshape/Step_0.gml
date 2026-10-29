if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
if (obj_battlebox.state == "closing") fading = true;
if (fading)
{
    image_alpha -= 0.1;
    if (image_alpha <= 0) instance_destroy();
    exit;
}

t++;
image_alpha = min(1, image_alpha + 0.05);
angle += spin;
track  = max(0, track - track_decay);   // wears off from the moment it appears, even while it waits

if (t > wait_time && instance_exists(obj_soul))
{
    var _sx = obj_soul.x, _sy = obj_soul.y;
    var _aura = instance_exists(ctrl) ? ctrl.aura_radius : 48;

    // the light can't purify it, only slow it down to half speed
    if (point_distance(x, y, _sx, _sy) < _aura + 8) spd = scr_approach(spd, speed_max * 0.5, spd * 0.125);
    else                                             spd = scr_approach(spd, speed_max, accel);

    // homes in, less and less as `track` wears off
    if (track > 0) dir += angle_difference(point_direction(x, y, _sx, _sy), dir) * track * 0.16;

    x += lengthdir_x(spd, dir);
    y += lengthdir_y(spd, dir);
}

// afterimages while it's moving fast
if (spd > 1 && t mod 2 == 0) array_push(trail, { x: x, y: y, a: angle, al: 0.3 });
for (var i = array_length(trail) - 1; i >= 0; i--)
{
    trail[i].al -= 0.03;
    if (trail[i].al <= 0) array_delete(trail, i, 1);
}

// it goes straight through the SOUL (the SOUL's flash stops it hitting twice)
if (instance_exists(obj_soul) && !obj_soul.invulnerable && point_distance(x, y, obj_soul.x, obj_soul.y) <= hit_radius)
    scr_soul_take_hit(damage, c_white, c_white);

// gone once it's well clear of the box
var _c = scr_box_center();
if (t > wait_time && point_distance(x, y, _c.x, _c.y) > 500) instance_destroy();