// drawn on whichever side of the tower's seam is on screen
var _ox = scr_plat_draw_x(cx) - cx;

if (kind == "swarm")
{
    if (!burst_done)
    {
        // the three fires swirling in on it
        var _k = t / swarm_len;
        var _r = lerp(swarm_r_from, swarm_r_to, _k * _k);
        for (var i = 0; i < swarm_count; i++)
        {
            var _a = spin0 + i * 360 / swarm_count + t * swarm_spin;
            draw_sprite_ext(swarm_sprite, 0, cx + _ox + lengthdir_x(_r, _a), cy + lengthdir_y(_r, _a),
                            swarm_scale, swarm_scale, 0, c_white, 1);
        }
    }
    else
    {
        // the ring of small ones, fading out
        var _a = 1 - (t - swarm_len) / burst_len;
        for (var i = 0; i < array_length(bursts); i++)
            draw_sprite_ext(burst_sprite, 0, bursts[i].x + _ox, bursts[i].y, burst_scale, burst_scale, 0, c_white, _a);
    }
}
else
{
    // the Rude Buster blowing out on it
    var _k = t / buster_len;
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(spr_rudebuster_projectile, 0, cx + _ox, cy, 1 + _k * 1.5, 1 + _k * 1.5, 0, c_white, 1 - _k);
    gpu_set_blendmode(bm_normal);
}