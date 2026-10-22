var _vt = camera_get_view_y(view_camera[0]) - 20;
var _vb = _vt + camera_get_view_height(view_camera[0]) + 40;

// the dark fountain column, behind everything: it's what's left when the geyser fizzles
if (dark_visible)
{
    var _bot = min(base_bottom_y, _vb);
    var _hw  = pillar_w / 2;
    draw_set_color(c_black);
    draw_rectangle(fx - _hw, _vt, fx + _hw, _bot, false);
    var _th = sprite_get_height(spr_fountain) * dark_scale;
    draw_column(spr_fountain, 0, base_bottom_y + _th - (dark_scroll mod _th), _vt, _bot, dark_scale, dark_col, 1);
    gpu_set_blendmode(bm_add);
    draw_column(spr_fountain, 0, base_bottom_y + _th - ((dark_scroll2 + _th / 3) mod _th), _vt, _bot, dark_scale, dark_col2, 0.6);
    gpu_set_blendmode(bm_normal);
}

// the pool: black, with the white flash fading off it
if (show_pool && !show_burst && !show_geyser && !show_fizzle)
    draw_pool(spr_titan_fountain_burst_base, 0, 1);
if (pool_white > 0)
    draw_pool(spr_titan_fountain_loop_base_white, 0, pool_white);

// the burst
if (show_burst)
{
    var _i = clamp(floor(frame), 0, sprite_get_number(spr_titan_fountain_burst) - 1);
    draw_pool(spr_titan_fountain_burst_base, _i, 1);
    draw_pool(spr_titan_fountain_burst, _i, 1);
}

// the geyser, all the way up the screen
if (show_geyser)
{
    var _li = floor(loop_frame);
    draw_pool(spr_titan_fountain_loop_base, _li mod sprite_get_number(spr_titan_fountain_loop_base), 1);
    draw_column(spr_titan_fountain_loop, _li mod sprite_get_number(spr_titan_fountain_loop), base_bottom_y, _vt, _vb);
    draw_pool(spr_titan_fountain_loop_rings, _li mod sprite_get_number(spr_titan_fountain_loop_rings), 1);
}

// ...fizzling out: one copy with its top at the top of the screen, like the game
if (show_fizzle)
{
    var _vy = camera_get_view_y(view_camera[0]);
    draw_sprite_ext(spr_tower_fizzleout, fizzle_frame, fx, _vy + sprite_get_yoffset(spr_tower_fizzleout) * scale,
                    scale, scale, 0, c_white, 1);
}

if (petrify_started)
{
    // under the bottom of the screen it's just stone
    var _floor = cam_bottom + 40;
    if (_floor < base_bottom_y)
    {
        draw_column(spr_titantower_piece,    0, base_bottom_y, max(_floor, _vt), min(base_bottom_y, _vb), tower_scale);
        draw_column(spr_titantower_gradient, 0, base_bottom_y, max(_floor, _vt), min(base_bottom_y, _vb), tower_scale);
    // the tower darkens toward its base
    if (tower_shade > 0)
    {
        var _hw2 = pillar_w / 2, _y0 = base_bottom_y - tower_shade_h;
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_colour(fx - _hw2, _y0,           c_black, 0);
        draw_vertex_colour(fx + _hw2, _y0,           c_black, 0);
        draw_vertex_colour(fx - _hw2, base_bottom_y, c_black, tower_shade);
        draw_vertex_colour(fx + _hw2, base_bottom_y, c_black, tower_shade);
        draw_primitive_end();
    }
    }

    // the stone sections, building up the screen
    for (var i = 0; i < array_length(segs); i++)
    {
        var _s = segs[i];
        draw_sprite_ext(spr_tower_petrification, anim_frame(spr_tower_petrification, cur_g2, _s.born, seg_speed),
                        _s.x, _s.y, scale, scale, 0, c_white, 1);
    }

    // their ghosts, stretching out and fading
    for (var i = 0; i < array_length(ghosts); i++)
    {
        var _gh = ghosts[i];
        var _k  = clamp((cur_g2 - _gh.born) / ghost_len_g, 0, 1);
        draw_sprite_ext(spr_tower_petrification, _gh.img, _gh.x, _gh.y, scale * (1 + ghost_grow * _k), scale, 0, c_white, ghost_alpha * (1 - _k));
    }
}

// the pillar bursting open
if (is_struct(handburst))
    draw_sprite_ext(spr_tower_handburst, anim_frame(spr_tower_handburst, cur_g3, handburst.born, handburst_speed),
                    handburst.x, handburst.y, scale, scale, 0, c_white, 1);

// the hand
if (show_hand)
    draw_sprite_ext(spr_tower_titanhand, floor(hand_frame), hand_x, hand_y, scale, scale, 0, c_white, 1);

// the pillar's broken front edge, in front of the hand's arm
if (is_struct(foreground))
    draw_sprite_ext(spr_tower_handburst_foreground, 0, foreground.x, foreground.y, scale, scale, 0, c_white, 1);

// the burst's debris, sliding off to the right after a beat
if (is_struct(handburst))
{
    var _dx = max(0, cur_g3 - handburst.born - hb_debris_move_g) * hb_debris_hspeed;
    draw_sprite_ext(spr_tower_handburst_debris, anim_frame(spr_tower_handburst_debris, cur_g3, handburst.born, handburst_speed),
                    handburst.x + _dx, handburst.y, scale, scale, 0, c_white, 1);
}

// the cracks (the first one opens an eye)
for (var i = 0; i < array_length(cracks); i++)
{
    var _c = cracks[i];
    draw_sprite_ext(_c.spr,    anim_frame(_c.spr,    cur_g3, _c.born, crack_speed), _c.x, _c.y, scale, scale, 0, c_white, 1);
    draw_sprite_ext(_c.debris, anim_frame(_c.debris, cur_g3, _c.born, crack_speed), _c.x, _c.y, scale, scale, 0, c_white, 1);
}

// the beam
if (show_beam)
    draw_sprite_ext(beam_spr, beam_img, beam_x, beam_y, scale, scale, beam_angle, c_white, 1);

// the rocks, in front of everything
for (var i = 0; i < array_length(debris); i++)
{
    var _d = debris[i];
    draw_sprite_ext(spr_tower_handburst_debris_isolated, _d.img, _d.x, _d.y, scale, scale, 0, c_white, 1);
}

draw_set_color(c_white);