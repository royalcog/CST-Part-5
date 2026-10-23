if (dying)
{
    die_t++;
    image_alpha = 1 - die_t / die_len;
    base_y -= 0.6;   // drifts up as it fades
    x += vx * 0.5; vx *= 0.9;
    x = scr_plat_wrap(x);
    y = base_y;
    if (die_t >= die_len) instance_destroy();
    exit;
}

// back to its idle once it's done shuddering
if (hurt_t > 0)
{
    hurt_t--;
    if (hurt_t == 0) { sprite_index = spr_titanspawn_idle; image_index = 0; }
}

// float toward whoever you're controlling (their middle), the short way around the tower
var _ctl = instance_exists(obj_plat_controller) ? instance_find(obj_plat_controller, 0) : noone;
if (_ctl != noone && hurt_t <= 0)
{
    var _l  = _ctl.leader();
    var _d  = point_direction(0, 0, scr_plat_wrap_dx(x, _l.x), (_l.y - _l.hh / 2) - base_y);
    vx = lerp(vx, lengthdir_x(spd, _d), turn);
    vy = lerp(vy, lengthdir_y(spd, _d), turn);
}
else
{
    vx *= 0.9;
    vy *= 0.9;
}
x      += vx;
x       = scr_plat_wrap(x);
base_y += vy;
bob    += bob_speed;
y = base_y + sin(bob) * bob_amp;

// face where it's going
if (abs(vx) > 0.1) image_xscale = 2 * ((vx > 0) == faces_left ? -1 : 1);

// touching either of them hurts
if (hurt_t <= 0)
{
    with (obj_plat_player)
    {
        var _sx = x + scr_plat_wrap_dx(x, other.x);   // the spawn, on this side of the tower
        if (point_in_rectangle(_sx, other.y, x - hw - other.touch_r, y - hh - other.touch_r, x + hw + other.touch_r, y + other.touch_r))
            take_hit(_sx, irandom_range(other.damage_min, other.damage_max));
    }
}