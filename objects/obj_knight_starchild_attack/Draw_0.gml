var _spr = spr_roark_starchild;
var _glow_at = attack_length - glow_frames;
var _glow = clamp((t - _glow_at) / glow_frames, 0, 1);

// stars (red builds up and they swell/pulse right before going off)
for (var i = 0; i < array_length(stars); i++)
{
    var _s = stars[i];
    var _a = _s.alpha * fade_out;
    var _sc = star_scale * (1 + glow_pulse * _glow * (0.5 + 0.5 * sin(t * (0.25 + _glow * 0.5))));

    draw_sprite_ext(_spr, 0, _s.x, _s.y, _sc, _sc, _s.dir, c_white, _a);
    if (_glow > 0)
    {
        gpu_set_fog(true, c_red, 0, 1);
        draw_sprite_ext(_spr, 0, _s.x, _s.y, _sc, _sc, _s.dir, c_white, _a * _glow);
        gpu_set_fog(false, c_black, 0, 0);
    }
}

// shards (start red, cool off to normal, fade at the end)
for (var i = 0; i < array_length(shards); i++)
{
    var _h = shards[i];
    var _a = clamp((shard_life - _h.t) / shard_fade, 0, 1) * fade_out;
    var _red = clamp(1 - _h.t / 25, 0, 1);

    draw_sprite_ext(_spr, 0, _h.x, _h.y, shard_scale, shard_scale, _h.angle, c_white, _a);
    if (_red > 0)
    {
        gpu_set_fog(true, c_red, 0, 1);
        draw_sprite_ext(_spr, 0, _h.x, _h.y, shard_scale, shard_scale, _h.angle, c_white, _a * _red);
        gpu_set_fog(false, c_black, 0, 0);
    }
}

// burst flashes
gpu_set_blendmode(bm_add);
for (var i = 0; i < array_length(flashes); i++)
{
    var _f = flashes[i];
    var _k = _f.t / flash_frames;
    draw_set_color(c_white);
    draw_set_alpha((1 - _k) * 0.8 * fade_out);
    draw_circle(_f.x, _f.y, flash_radius * (0.4 + 0.6 * _k), false);
}
draw_set_alpha(1);
gpu_set_blendmode(bm_normal);