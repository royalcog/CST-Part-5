if (appear_t < appear_len) appear_t++;

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

// the scene's two: come in fast, then slow right down and hover behind their hero
if (scripted && instance_exists(target_hero) && hurt_t <= 0)
{
    var _hx   = target_hero.x + hold_side * hold_dist;
    var _dx   = scr_plat_wrap_dx(x, _hx);
    var _dy   = (target_hero.y - target_hero.hh / 2) - base_y;
    var _dist = point_distance(0, 0, _dx, _dy);
    if (_dist < 2)
    {
        vx = 0;
        vy = 0;
        arrived = true;
    }
    else
    {
        var _sp = max(0.5, fast_spd * min(1, _dist / slow_r));
        var _d  = point_direction(0, 0, _dx, _dy);
        vx = lengthdir_x(min(_sp, _dist), _d);
        vy = lengthdir_y(min(_sp, _dist), _d);
        if (_dist < 8) arrived = true;
    }
    // look at the hero it's after
    image_xscale = 2 * ((scr_plat_wrap_dx(x, target_hero.x) > 0) == faces_left ? -1 : 1);
}

// everyone else: float toward whoever you're controlling (their middle), the short way around the tower
else
{
    var _ctl = instance_exists(obj_plat_controller) ? instance_find(obj_plat_controller, 0) : noone;
    if (_ctl != noone && hurt_t <= 0)
    {
        var _l = _ctl.leader();
        var _d = point_direction(0, 0, scr_plat_wrap_dx(x, _l.x), (_l.y - _l.hh / 2) - base_y);
        vx = lerp(vx, lengthdir_x(spd, _d), turn);
        vy = lerp(vy, lengthdir_y(spd, _d), turn);
    }
    else
    {
        vx *= 0.9;
        vy *= 0.9;
    }
}

x      += vx;
x       = scr_plat_wrap(x);
base_y += vy;
bob    += bob_speed;
y = base_y + sin(bob) * bob_amp;

// face where it's going
if (abs(vx) > 0.1 && !scripted) image_xscale = 2 * ((vx > 0) == faces_left ? -1 : 1);

// touching either of them hurts
if (hurt_t <= 0 && appear_t >= appear_len && !scripted)
{
    with (obj_plat_player)
    {
        var _sx = x + scr_plat_wrap_dx(x, other.x);   // the spawn, on this side of the tower
        if (point_in_rectangle(_sx, other.y, x - hw - other.touch_r, y - hh - other.touch_r, x + hw + other.touch_r, y + other.touch_r))
            take_hit(_sx, irandom_range(other.damage_min, other.damage_max));
    }
}