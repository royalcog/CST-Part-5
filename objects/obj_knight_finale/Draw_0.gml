// --- Ralsei's barrier: a curved band of light ---
if (barrier.on)
{
    var _g  = 1 - power(1 - barrier.grow, 3);
    var _ha = barrier_arc * _g;              // grows out from its middle
    var _p  = 0.75 + 0.25 * sin(barrier.t * 0.2);
    var _n  = 28;
    var _th = barrier_th;

    gpu_set_blendmode(bm_add);
    draw_set_color(ralsei_color);

    // soft glow, then the band itself
    for (var _pass = 0; _pass < 2; _pass++)
    {
        var _w = (_pass == 0) ? _th * 2.2 : _th;
        draw_set_alpha((_pass == 0) ? 0.15 * _p : 0.4 * _p);
        draw_primitive_begin(pr_trianglestrip);
        for (var i = 0; i <= _n; i++)
        {
            var _a = lerp(-_ha, _ha, i / _n);
            var _in = barrier_point(_a, -_w / 2), _out = barrier_point(_a, _w / 2);
            draw_vertex(_in.x, _in.y);
            draw_vertex(_out.x, _out.y);
        }
        draw_primitive_end();
    }

    // bright edges
    draw_set_alpha(0.9 * _p);
    for (var i = 0; i < _n; i++)
    {
        var _a1 = lerp(-_ha, _ha, i / _n), _a2 = lerp(-_ha, _ha, (i + 1) / _n);
        var _o1 = barrier_point(_a1, _th / 2), _o2 = barrier_point(_a2, _th / 2);
        var _i1 = barrier_point(_a1, -_th / 2), _i2 = barrier_point(_a2, -_th / 2);
        draw_line_width(_o1.x, _o1.y, _o2.x, _o2.y, 2);
        draw_line_width(_i1.x, _i1.y, _i2.x, _i2.y, 1);
    }

    // glints running along it
    draw_set_color(c_white);
    for (var k = 0; k < 3; k++)
    {
        var _a = lerp(-_ha, _ha, frac(barrier.t / 70 + k / 3));
        var _q = barrier_point(_a, 0);
        draw_set_alpha(0.6 * _p);
        draw_circle(_q.x, _q.y, 3, false);
    }

    // flash on every hit
    if (barrier.flash > 0)
    {
        draw_set_alpha(barrier.flash * 0.7);
        draw_primitive_begin(pr_trianglestrip);
        for (var i = 0; i <= _n; i++)
        {
            var _a = lerp(-_ha, _ha, i / _n);
            var _in = barrier_point(_a, -_th), _out = barrier_point(_a, _th);
            draw_vertex(_in.x, _in.y);
            draw_vertex(_out.x, _out.y);
        }
        draw_primitive_end();
    }
    gpu_set_blendmode(bm_normal);

    // cracks
    draw_set_color(c_white);
    draw_set_alpha(0.9);
    for (var k = 0; k < array_length(barrier.cracks); k++)
    {
        var _ck = barrier.cracks[k];
        draw_line_width(_ck.x1, _ck.y1, _ck.x2, _ck.y2, 1);
    }
    draw_set_alpha(1);
}

// --- barrier shards ---
gpu_set_blendmode(bm_add);
draw_set_color(ralsei_color);
for (var i = 0; i < array_length(shards); i++)
{
    var _p = shards[i];
    draw_set_alpha(1 - _p.t / 45);
    draw_line_width(_p.x - lengthdir_x(_p.len, _p.rot), _p.y - lengthdir_y(_p.len, _p.rot),
                    _p.x + lengthdir_x(_p.len, _p.rot), _p.y + lengthdir_y(_p.len, _p.rot), 2);
}
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);

// --- spades + chunks ---
for (var i = 0; i < array_length(spades); i++)
{
    var _s = spades[i];
    draw_sprite_ext(spr_spade, 0, _s.x, _s.y, spade_scale, spade_scale, _s.rot, c_white, 1);
}
for (var i = 0; i < array_length(chunks); i++)
{
    var _c = chunks[i];
    draw_sprite_ext(spr_spadechunk, 0, _c.x, _c.y, 0.35, 0.35, _c.rot, c_white, 1 - _c.t / 30);
}

// --- heal beam ---
if (beam.on)
{
    var _n = array_length(beam.trail);
    for (var j = _n - 1; j >= 0; j--)
    {
        var _tr = beam.trail[j];
        draw_sprite_ext(spr_healbeam, floor(beam.frame) mod sprite_get_number(spr_healbeam), _tr.x, _tr.y,
                        beam_scale, beam_scale, beam.dir, c_white, 0.35 * (1 - (j + 1) / (_n + 1)));
    }
    gpu_set_blendmode(bm_add);
    draw_set_color(ralsei_color);
    draw_set_alpha(0.35);
    draw_circle(beam.x, beam.y, 10, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_sprite_ext(spr_healbeam, floor(beam.frame) mod sprite_get_number(spr_healbeam), beam.x, beam.y,
                    beam_scale, beam_scale, beam.dir, c_white, 1);
}

// --- the Knight's ball heading into the door (same size all the way, fading out) ---
if (ball.on && ball.alpha > 0)
{
    var _w = sprite_get_width(spr_roark_ball), _h = sprite_get_height(spr_roark_ball);
    var _sx = ball.scale * ball.xs;
    // the sprite's origin is its top-left, so offset to draw it centred on ball.x/ball.y
    var _dx = ball.x - (_w / 2) * _sx;
    var _dy = ball.y - (_h / 2) * ball.scale;
    draw_sprite_ext(spr_roark_ball, floor(ball.frame) mod sprite_get_number(spr_roark_ball), _dx, _dy,
                    _sx, ball.scale, 0, c_white, ball.alpha);
}