if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
if (obj_battlebox.state == "closing") fading = true;
if (fading)
{
    image_alpha -= 0.1;
    if (image_alpha <= 0) instance_destroy();
    exit;
}

image_alpha = min(1, image_alpha + 0.05);
grow        = min(1, grow + 0.05);
anim_f     += anim_speed;

// chase the soul (DR's chase_heart)
if (instance_exists(obj_soul))
{
    var _sx = obj_soul.x, _sy = obj_soul.y;
    var _aura = instance_exists(ctrl) ? ctrl.aura_radius : 40;

    if (point_distance(x, y, _sx, _sy) < _aura + 8)
    {
        // in the light: slows right down and purifies
        myspeed = scr_approach(myspeed, (0.7 + (1 - light)) * 0.5, 0.0375);
        light   = scr_approach(light, 1, light_rate);
        if (instance_exists(ctrl))
        {
            ctrl.in_light = true;
            if (!irandom(2)) array_push(ctrl.particles, {
                x: x + random_range(-12, 12), y: y + random_range(-12, 12),
                dir: point_direction(_sx, _sy, x, y), spd: 0.5 + random(1.5), size: 2
            });
        }
    }
    else
    {
        myspeed = scr_approach(myspeed, speed_max, accel * (1 - light));
        light   = scr_approach(light, 0, light_recover);
    }

    dir += angle_difference(point_direction(x, y, _sx, _sy), dir) / tracking_val;
    x += lengthdir_x(myspeed, dir);
    y += lengthdir_y(myspeed, dir);
}

// copies push each other apart (DR's do_pushback)
with (obj_darkshape)
{
    if (id != other.id && point_distance(x, y, other.x, other.y) < other.pushback_radius)
    {
        var _a = point_direction(other.x, other.y, x, y);
        x += lengthdir_x(0.5, _a);
        y += lengthdir_y(0.5, _a);
    }
}

// shrivel stage + hitbox (DR's do_shrivel)
if      (light > 0.99) { stage = 5; }
else if (light > 0.8)  { stage = 4; radius = 8;  }
else if (light > 0.6)  { stage = 3; radius = 10; }
else if (light > 0.4)  { stage = 2; radius = 13; }
else if (light > 0.2)  { stage = 1; radius = 16; }
else                   { stage = 0; radius = 20; }

// fully purified: drops a pellet (DR's check_death)
if (light >= 1)
{
    instance_create_depth(x, y, depth, obj_darkshape_greenblob);
    if (instance_exists(ctrl)) { ctrl.dark_count++; ctrl.burst = 1; }
    instance_destroy();
    exit;
}

// touched the soul
if (instance_exists(obj_soul) && !obj_soul.invulnerable
 && point_distance(x, y, obj_soul.x, obj_soul.y) <= radius * hit_mult * scalefactor + 4)
{
    scr_soul_take_hit(damage, c_white, c_white);
    instance_destroy();
}