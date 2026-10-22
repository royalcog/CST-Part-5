t++;

switch (state)
{
    case "summon":
    {
        var _k = clamp(t / summon_time, 0, 1);
        base_y = lerp(from_y, home_y, 1 - power(1 - _k, 3));   // eases to a stop
        if (_k >= 1) { state = "hover"; t = 0; }
    }
    break;

    case "dip":
    {
        var _k = clamp(t / dip_time, 0, 1);
        base_y = from_y + dip_dist * sin(_k * pi / 2);
        if (_k >= 1) { state = "wait"; t = 0; }
    }
    break;

    case "wait":
        if (t >= lift_wait)
        {
            state  = "fly";
            t      = 0;
            from_y = base_y;
            if (fly_sound != noone) audio_play_sound(fly_sound, 1, false);
        }
    break;

    case "fly":
    {
        var _k = clamp(t / fly_time, 0, 1);
        base_y = from_y - fly_dist * _k * _k * _k;   // slow start, then it's gone
        if (_k >= 1)
        {
            for (var i = 0; i < array_length(riders); i++)
                if (instance_exists(riders[i].inst)) instance_destroy(riders[i].inst);
            riders = [];
            state = "gone";
            var _cb = on_gone;
            on_gone = undefined;
            if (_cb != undefined) _cb();
            instance_destroy();
            exit;
        }
    }
    break;
}

// the float (eases out while it's flying off)
bob += bob_speed;
var _bob_amt = (state == "fly") ? bob_amp * max(0, 1 - t / 20) : bob_amp;
y = round(base_y + sin(bob) * _bob_amt);

// riders: hopping on, or stuck to their spot
for (var i = 0; i < array_length(riders); i++)
{
    var _r = riders[i];
    if (!instance_exists(_r.inst)) continue;
    var _s = seat_point(_r.dx, _r.dy);

    if (_r.hopping)
    {
        _r.t++;
        var _k = clamp(_r.t / _r.len, 0, 1);
        // arc from where they stood onto the seat (which might be bobbing)
        var _hx = lerp(_r.fx, _s.x, _k);
        var _hy = lerp(_r.fy, _s.y, _k) - sin(_k * pi) * _r.h;
        set_feet(_r.inst, round(_hx), round(_hy));
        if (_k >= 1)
        {
            _r.hopping = false;
            if (_r.land_sprite != noone) scr_set_sprite_keep_feet(_r.inst, _r.land_sprite);
            set_feet(_r.inst, _s.x, _s.y);
            if (_r.done != undefined) { var _cb = _r.done; _r.done = undefined; _cb(); }
        }
    }
    else set_feet(_r.inst, _s.x, _s.y);
}

// same shadow as everyone else on the platform
if (instance_exists(obj_shadow_tint))
    image_blend = merge_color(c_white, obj_shadow_tint.tint_col, obj_shadow_tint.shade_at(y + bottom_dy));