// the soul's light (Deltarune draws it in code too): soft shimmering layers, a bright core, a pulsing edge
if (instance_exists(obj_soul))
{
    var _sx = round(obj_soul.x), _sy = round(obj_soul.y);
    var _pulse = 0.5 + 0.5 * sin(t * 0.08);
    gpu_set_blendmode(bm_add);
    draw_set_colour(c_white);
    for (var i = 0; i < 8; i++)
    {
        draw_set_alpha(glow_strength * (0.07 + 0.02 * sin(t * 0.11 + i * 0.9)));
        draw_circle(_sx, _sy, aura_radius * (1 - i / 9), false);
    }
    draw_set_alpha(glow_strength * (0.3 + 0.15 * _pulse));
    draw_circle(_sx, _sy, aura_radius, true);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

// specks
draw_set_colour(c_white);
for (var i = 0; i < array_length(particles); i++)
{
    var _p = particles[i];
    draw_rectangle(_p.x - _p.size, _p.y - _p.size, _p.x + _p.size, _p.y + _p.size, false);
}