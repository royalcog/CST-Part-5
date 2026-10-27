// the soul's light (Deltarune draws it in code too)
if (instance_exists(obj_soul))
{
    var _sx = round(obj_soul.x), _sy = round(obj_soul.y);
    gpu_set_blendmode(bm_add);
    draw_set_colour(c_white);
    for (var i = 0; i < 6; i++)
    {
        draw_set_alpha(0.05);
        draw_circle(_sx, _sy, aura_radius * (1 - i / 7), false);
    }
    draw_set_alpha(0.25);
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