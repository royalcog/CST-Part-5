var _cx = camera_get_view_x(view_camera[0]), _cy = camera_get_view_y(view_camera[0]);

// ---------------------------------------------------------------- the flashback's black
if (fb.a > 0)
{
    draw_set_alpha(fb.a);
    draw_set_colour(c_black);
    draw_rectangle(_cx - 32, _cy - 32, _cx + vw + 32, _cy + vh + 32, false);
    draw_set_alpha(1);
}

// ---------------------------------------------------------------- Ralsei (light green, glowing) and King (blue)
if (fb.sa > 0)
{
    var _rc = merge_colour(col_ralsei, col_ralsei_red, fb.red);
    var _ga = fb.sa * (glow_alpha + glow_pulse * sin(t * glow_speed) + glow_red_extra * fb.red);
    gpu_set_blendmode(bm_add);
    for (var i = 0; i < 8; i++) sil(obj_ralsei, _rc, _ga, lengthdir_x(glow_dist, i * 45), lengthdir_y(glow_dist, i * 45));
    gpu_set_blendmode(bm_normal);
    sil(obj_ralsei, _rc, fb.sa);
    sil(obj_king, col_king, fb.sa);
}

// ---------------------------------------------------------------- the inferno's glow
if (inferno != undefined && inferno.t < inferno_time + 40)
{
    var _ia = (inferno.t < inferno_time) ? min(1, inferno.t / 15) : 1 - (inferno.t - inferno_time) / 40;
    var _k = mid(obj_king);
    gpu_set_blendmode(bm_add);
    draw_set_alpha(_ia);
    draw_circle_colour(_k.x, _k.y, inferno_w * 2.4, c_orange, c_black, false);
    draw_circle_colour(_k.x, _k.y - 20, inferno_w * 1.4, c_yellow, c_black, false);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

// ---------------------------------------------------------------- the wheel of fire
if (wheel != undefined && !wheel.gone)
{
    var _m = mid(obj_ralsei);
    var _e = wheel.k * wheel.k * (3 - 2 * wheel.k);
    var _r = wheel_radius * _e * (1 - wheel.ek);
    var _a = _e * (1 - wheel.ek);
    for (var i = 0; i < wheel_count; i++)
    {
        var _ang = wheel.rot + i * 360 / wheel_count;
        fire_draw(spr_plat_fire, 0, _m.x + lengthdir_x(_r, _ang), _m.y + lengthdir_y(_r, _ang), 1 - wheel.ek * 0.5, 0, _a);
    }
}

// ---------------------------------------------------------------- fireballs, King's spades, bits
for (var i = 0; i < array_length(shots); i++)
{
    var _s = shots[i];
    fire_draw(spr_plat_fireball, floor(_s.f) mod sprite_get_number(spr_plat_fireball), _s.x, _s.y, shot_scale, _s.dir, 1);
}
for (var i = 0; i < array_length(kspades); i++)
{
    var _p = kspades[i];
    if (fb.sa > 0) gpu_set_fog(true, col_king, 0, 0);
    draw_sprite_ext(spr_spade, 0, _p.x, _p.y, kspade_scale, kspade_scale, _p.rot, c_white, 1);
    gpu_set_fog(false, c_black, 0, 0);
}
for (var i = 0; i < array_length(bits); i++)
{
    var _b = bits[i];
    var _a = 1 - _b.t / _b.life;
    if (_b.glow) fire_draw(_b.spr, 0, _b.x, _b.y, _b.s, _b.rot, _a);
    else
    {
        if (_b.col != -1) gpu_set_fog(true, _b.col, 0, 0);
        draw_sprite_ext(_b.spr, 0, _b.x, _b.y, _b.s, _b.s, _b.rot, c_white, _a);
        gpu_set_fog(false, c_black, 0, 0);
    }
}

// ---------------------------------------------------------------- Queen's shield (builds up from the bottom)
if (shield != undefined)
{
    var _w = sprite_get_width(spr_queen_shield), _h = sprite_get_height(spr_queen_shield);
    var _k = clamp(shield.t / shield_build, 0, 1);
    var _rows = max(1, round(_h * _k));
    var _by = shield.y + sin(shield.bob) * shield_bob_amp;
    var _top = _by - _rows * shield_scale;
    draw_sprite_part_ext(spr_queen_shield, 0, 0, _h - _rows, _w, _rows, shield.x, _top, shield_scale, shield_scale, c_white, min(1, _k * 2));
    if (shield.flash > 0)
    {
        gpu_set_fog(true, c_white, 0, 0);
        draw_sprite_part_ext(spr_queen_shield, 0, 0, _h - _rows, _w, _rows, shield.x, _top, shield_scale, shield_scale, c_white, shield.flash);
        gpu_set_fog(false, c_black, 0, 0);
    }
}

// ---------------------------------------------------------------- after the battle
// the red glow pulsing over Ralsei while he pushes
if (rage_tint > 0)
{
    gpu_set_blendmode(bm_add);
    sil(obj_ralsei, col_ralsei_red, rage_tint * (0.25 + 0.15 * sin(t * 0.3)));
    gpu_set_blendmode(bm_normal);
}
// the Titan's dark glow as it heals
if (titan_glow > 0 && instance_exists(obj_titan_reveal))
{
    var _tx = obj_titan_reveal.x + titan_aim.x, _ty = obj_titan_reveal.y + titan_aim.y;
    gpu_set_blendmode(bm_add);
    draw_set_alpha(titan_glow);
    draw_circle_colour(_tx, _ty, 140, heal_col, c_black, false);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}
// explosions
for (var i = 0; i < array_length(blasts); i++)
{
    var _b = blasts[i];
    draw_sprite_ext(_b.spr, floor(_b.f), _b.x, _b.y, _b.s, _b.s, _b.ang, c_white, 1);
}

// ---------------------------------------------------------------- the standoff
if (beam != undefined && beam.phase != "done")
{
    var _a  = beam_from(), _tf = titan_pt(titan_face), _c = beam_clash();
    // its laser, from its face in to where they meet
    draw_laser(_tf.x, _tf.y, lerp(_tf.x, _c.x, beam.lk), lerp(_tf.y, _c.y, beam.lk), laser_w * (0.6 + 0.4 * beam.la), beam.la);
    // his fire, from his hand out to where they meet
    draw_fire_beam(_a.x, _a.y, lerp(_a.x, _c.x, beam.fk), lerp(_a.y, _c.y, beam.fk), fire_beam_w * max(0.15, beam.fw), beam.fa);
    // where they meet
    if (beam.phase != "grow")
    {
        gpu_set_blendmode(bm_add);
        draw_set_alpha(0.6 * beam.fa);
        draw_circle_colour(_c.x, _c.y, 26 + sin(t * 0.5) * 6, c_white, c_black, false);
        draw_set_alpha(1);
        gpu_set_blendmode(bm_normal);
    }
}
// ---------------------------------------------------------------- its laser at him (its face glows, then it fires)
if (laser != undefined)
{
    var _tf = titan_pt(titan_face);
    var _gk = (laser.phase == "charge") ? laser.t / laser_charge : 1;
    gpu_set_blendmode(bm_add);
    draw_set_alpha(_gk * laser.a);
    draw_circle_colour(_tf.x, _tf.y, 20 + 40 * _gk, c_white, c_black, false);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
    if (laser.phase != "charge")
    {
        // from the star, through him, off the far side of the screen
        var _m = mid(obj_ralsei);
        var _d = point_direction(_tf.x, _tf.y, _m.x, _m.y);
        var _l = point_distance(_tf.x, _tf.y, _m.x, _m.y) + vw + vh;
        draw_laser(_tf.x, _tf.y, _tf.x + lengthdir_x(_l, _d), _tf.y + lengthdir_y(_l, _d), laser_w * 1.4, laser.a);
    }
}
// ---------------------------------------------------------------- Pink's bomb
if (bomb != undefined && !bomb.done)
{
    var _k  = bomb.t / bomb_time;
    var _bx = lerp(bomb.sx, bomb.tx, _k), _by = lerp(bomb.sy, bomb.ty, _k) - sin(_k * pi) * bomb_arc;
    draw_sprite_ext(spr_pinkbomb, 0, _bx, _by, 2, 2, bomb.rot, c_white, 1);
}

// ---------------------------------------------------------------- the inferno's flash
if (fb.flash > 0)
{
    gpu_set_blendmode(bm_add);
    draw_set_alpha(fb.flash * 0.8);
    draw_set_colour(c_white);
    draw_rectangle(_cx - 32, _cy - 32, _cx + vw + 32, _cy + vh + 32, false);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}
draw_set_colour(c_white);