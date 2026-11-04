var _ox = view_x(), _oy = view_y();

// ---------------------------------------------------------------- the intro (room px): the platforms coming up out of
// the clouds off the tower's edge, and the cloud bank rising in front of the sinking Titan
if (phase == "intro")
{
    for (var i = 0; i < pillars; i++)
    {
        if (pillar_k[i] <= 0) continue;
        var _k = pillar_k[i];
        var _e = 1 - (1 - _k) * (1 - _k);
        draw_pillar(pillar_x0 + i * pillar_dx, lerp(room_height + 40, pillar_y0 + i * pillar_dy, _e), pillar_n, room_height + 80);
    }
    if (bank_k > 0)
    {
        var _rise = bank_rise * (1 - bank_k) * (1 - bank_k);
        for (var _y = bank_top; _y < room_height + 60; _y += 34)
        for (var _x = 1180; _x < room_width + 60; _x += 40)
        {
            var _k = (_x div 40) * 7 + (_y div 34) * 13;
            puff(_x + ((_k mod 5) - 2) * 4 + sin(t / 40 + _k) * 3, _y + _rise + sin(t / 25 + _k) * 3,
                 2 + (_k mod 3) * 0.15, _k mod 3, lerp(0.3, 0.85, _y / room_height));
        }
    }
    exit;
}

// ---------------------------------------------------------------- the run (screen px from the camera)
// the sky and the sea, far to near: the far Titan and Queen's chair sit between the rows
draw_rectangle_colour(_ox - 8, _oy - 8, _ox + vw + 8, _oy + horizon_y, sky_top, sky_top, sky_low, sky_low, false);
draw_set_colour(sea_base);
draw_rectangle(_ox - 8, _oy + horizon_y, _ox + vw + 8, _oy + vh + 8, false);
draw_set_colour(c_white);
draw_rows(0, titan_far_z, _ox, _oy);
if (titan_far_k > 0) { var _fs = far_star(); draw_titan(_ox + _fs.x, _oy + _fs.y, titan_far_s); }
draw_rows(titan_far_z, queen_z, _ox, _oy);

// Queen's chair, Pink & Spamton on its arms, Jevil flying behind (gone once they show up at the end)
var _qa = (queen_k >= 0) ? 1 - ally_k[0] : 0;
if (_qa > 0)
{
    var _e  = 1 - power(1 - queen_k, 3);
    var _qs = 2 * lerp(queen_from.s, queen_to.s, _e);
    var _qx = _ox + lerp(queen_from.x, queen_to.x, _e);
    var _qy = _oy + lerp(queen_from.y, queen_to.y, _e) + sin(t / 20) * queen_bob;
    draw_sprite_ext(spr_jevil_dance, t * spd_of(spr_jevil_dance), _qx + jevil_trail.x * _qs, _qy + jevil_trail.y * _qs + sin(t / 14) * 3 * _qs, _qs, _qs, 0, c_white, _qa);
    // the chair with Queen in it, its flame under it, then Pink & Spamton sitting on its arms
    var _top = _qy - sprite_get_yoffset(spr_queen_chair_lookdown) * _qs;
    draw_sprite_ext(spr_queen_chair_flame, t * spd_of(spr_queen_chair_flame), _qx, _top + sprite_get_yoffset(spr_queen_chair_flame) * _qs, _qs, _qs, 0, c_white, _qa);
    draw_sprite_ext(spr_queen_chair_lookdown, 0, _qx, _qy, _qs, _qs, 0, c_white, _qa);
    draw_feet(spr_mewmew_idle_corrupted, t * spd_of(spr_mewmew_idle_corrupted), _qx + arm_l.x * _qs, _qy + arm_l.y * _qs, _qs, _qa);
    draw_feet(spr_spamton_right, 0, _qx + arm_r.x * _qs, _qy + arm_r.y * _qs, _qs, _qa);
}
draw_rows(queen_z, 1, _ox, _oy);

// the Titan, up at the edge (the end)
var _ns = { x: titan_near.x, y: titan_near.y + near_rise_dist * (1 - titan_near_k) };
if (titan_near_k > 0)
{
    draw_titan(_ox + _ns.x, _oy + _ns.y, titan_near_s);
    // the clouds it's rising out of, past the edge (over its bottom)
    var _ex = final_edge - dist;
    for (var _y = titan_near.y + 70; _y < vh + 40; _y += 30)
    for (var _x = _ex + 30; _x < vw + 60; _x += 38)
    {
        var _k = abs(floor(_x / 38) * 7 + floor(_y / 30) * 13);
        puff(_ox + _x + sin(t / 40 + _k) * 3, _oy + _y + sin(t / 25 + _k) * 3, 2.1, _k mod 3,
             lerp(cloud_light[0], cloud_light[1], (_y - horizon_y) / (vh - horizon_y)));
    }
}

// the platforms, then the nearest row of clouds over their bottoms
for (var i = 0; i < array_length(segs); i++)
{
    var _s = segs[i];
    var _sx = _s.x0 - dist;
    if (_sx > vw + 40 || _s.x1 - dist < -40) continue;
    draw_pillar(_ox + _sx, _oy + _s.y - stand_off, round((_s.x1 - _s.x0) / 40), _oy + vh + 60);
}
draw_rows(1, 2, _ox, _oy);

// the four of them, appearing behind Susie & Ralsei at the end (each flashes in white)
if (fin.st != "leap" && fin.st != "white" && fin.st != "black")
for (var i = 0; i < array_length(allies); i++)
{
    if (ally_k[i] <= 0) continue;
    var _a  = allies[i];
    var _ay = _oy + segs[array_length(segs) - 1].y - _a.up + ((_a.up > 0) ? sin(t / 14) * 4 : 0);
    var _ax = _ox + _a.x;
    var _img = _a.anim ? t * spd_of(_a.spr) : 0;   // (Queen stands still: only the idles move)
    draw_sprite_ext(_a.spr, _img, _ax, _ay, _a.s, _a.s, 0, c_white, ally_k[i]);
    if (ally_k[i] < 1)
    {
        gpu_set_fog(true, c_white, 0, 0);
        draw_sprite_ext(_a.spr, _img, _ax, _ay, _a.s, _a.s, 0, c_white, 1 - ally_k[i]);
        gpu_set_fog(false, c_white, 0, 0);
    }
    if (_a.shield)   // Queen's shield up
        draw_sprite_ext(spr_queen_shield_center_origin, 0, _ax + 34, _ay - 140, 1, 1, 0, c_white, 0.85 * ally_k[i]);
}

// Susie & Ralsei
var _ms = [ralsei, susie];
if (fin.st != "leap" && fin.st != "white" && fin.st != "black")
for (var i = 0; i < 2; i++)
{
    var _m = _ms[i];
    var _s = 2, _spr, _img = 0;
    var _su = (_m.who == "Susie");
    if (_m.pose == "defend")      { _spr = _su ? defend_susie : defend_ralsei; _s = battle_s; _img = sprite_get_number(_spr) - 1; }
    else if (_m.pose == "parry")  { _spr = _su ? parry_susie : parry_ralsei;   _s = battle_s; }
    else if (_m.atk != undefined) { _spr = atk_sprite(_m); _img = floor(_m.atk.t); }
    else if (!_m.grounded)        { _spr = _su ? spr_plat_susie_jump : spr_plat_ralsei_jump; _img = (_m.vy < -2) ? 0 : ((_m.vy < 2) ? 1 : 2); }
    else if (spd > 0)             { _spr = _su ? spr_plat_susie_run : spr_plat_ralsei_run; _img = dist / 40; }
    else                          { _spr = _su ? spr_plat_susie_unhappy : spr_plat_ralsei_idle; _img = t * spd_of(_spr); }
    var _al = (_m.invuln > 0 && (_m.invuln div 4) mod 2 == 0) ? 0.35 : 1;
    draw_sprite_ext(_spr, _img, _ox + _m.sx, _oy + _m.y, _s, _s, 0, c_white, _al);
    if (_m.fx > 0)   // a parry's flash
    {
        gpu_set_fog(true, parry_col, 0, 0);
        draw_sprite_ext(_spr, _img, _ox + _m.sx, _oy + _m.y, _s, _s, 0, c_white, _m.fx * 0.7);
        gpu_set_fog(false, c_white, 0, 0);
    }
}

// the Titan Spawn, and the ring closing in on it
if (spawn != undefined)
{
    var _p = spawn;
    var _spr = (_p.st == "dead") ? spr_titanspawn_hurt : spr_titanspawn_idle;
    var _al  = (_p.st == "dead") ? 1 - _p.dead / 30 : 1;
    draw_sprite_ext(_spr, t * spd_of(_spr), _ox + _p.x, _oy + _p.y, 2 * _p.s, 2 * _p.s, 0, c_white, _al);
    if (_p.st == "ring")
    {
        var _k   = min(1, _p.t / ring_time);
        var _r   = lerp(ring_r[0], ring_r[1], _k);
        var _now = abs(_p.t - ring_time) <= ring_window;
        var _col = _now ? c_white : ((_p.who == "Susie") ? dmg_cols.Susie : dmg_cols.Ralsei);
        for (var j = 0; j < 3; j++) draw_circle_colour(_ox + _p.x, _oy + _p.y, _r + j, _col, _col, true);
        draw_set_font(fnt_determination);
        draw_set_halign(fa_center);
        draw_set_colour(_col);
        draw_text(_ox + _p.x, _oy + _p.y - _r - 22, "X");
        draw_set_halign(fa_left);
        draw_set_colour(c_white);
    }
}

// the fish: diving in from its star (a ! where it'll land), then swimming along the path at them
for (var i = 0; i < array_length(orbs); i++)
{
    var _o  = orbs[i];
    var _tx = _o.wx - dist;
    if (!_o.landed)
    {
        var _k = _o.k;
        var _x = lerp(_o.sx0, _tx, _k), _y = lerp(_o.sy0, _o.y, _k) - sin(_k * pi) * 60;
        // it comes out of the star nose-down, and turns as it comes until it's lying flat facing them when it lands
        var _e = _k * _k * (3 - 2 * _k);
        draw_fish(_ox + _x, _oy + _y, lerp(250, 180, _e), lerp(0.3, fish_scale, _e), t * 0.22, min(1, _k * orb_time / fish_in_time));
        if ((t div 4) mod 2 == 0)
        {
            draw_set_font(fnt_determination);
            draw_set_halign(fa_center);
            draw_set_colour(_o.high ? c_yellow : c_red);
            draw_text(_ox + _tx, _oy + _o.y - 14, "!");
            draw_set_halign(fa_left);
            draw_set_colour(c_white);
        }
    }
    else draw_fish(_ox + _tx, _oy + _o.y, 180, fish_scale, t * 0.22);
}

// their shots
for (var i = 0; i < array_length(shots); i++)
{
    var _s = shots[i];
    draw_sprite_ext(_s.spr, t / 4, _ox + _s.x, _oy + _s.y, 2, 2, point_direction(_s.x0, _s.y0, _s.tx, _s.ty), c_white, 1);
}

// the end: its star charging, its laser against their parry
if (fin.st == "charge" || fin.st == "laser" || fin.st == "press")
{
    var _sx = _ox + _ns.x, _sy = _oy + _ns.y;
    if (fin.st == "charge")
    {
        var _g = fin.t / laser_charge;
        gpu_set_blendmode(bm_add);
        draw_set_alpha(_g);
        draw_circle_colour(_sx, _sy, (20 + 50 * _g) * laser_w / 14, c_white, c_black, false);
        draw_set_alpha(1);
        gpu_set_blendmode(bm_normal);
    }
    else
    {
        // their shield, pushed out toward it as the bar fills; its laser stops against the shield's front,
        // their fire beam runs from them into it
        var _fx  = _ox + susie.sx + 46, _fy = _oy + susie.y - 46;
        var _cx  = lerp(_fx, _sx, press_k * 0.85), _cy = lerp(_fy, _sy, press_k * 0.85);
        var _dir = point_direction(_cx, _cy, _sx, _sy);
        var _hx  = _cx + lengthdir_x(shield_r, _dir), _hy = _cy + lengthdir_y(shield_r, _dir);
        draw_beam(_sx, _sy, _hx, _hy, laser_w, 1, laser_col_glow, laser_col, laser_col_hot);
        if (press_on) draw_beam(_fx, _fy, _cx, _cy, laser_w * 0.7, 1, fire_col_glow, fire_col, fire_col_hot);
        draw_shield(_cx, _cy, _dir, 1);
        shield_pos = { x: _cx - _ox, y: _cy - _oy, dir: _dir };
    }
}

// knocked out: the laser's shoved back into its star, which flashes
if (fin.st == "leap" && fin.t < retract + 20)
{
    var _sx = _ox + _ns.x, _sy = _oy + _ns.y;
    if (fin.t < retract)
    {
        var _rk = fin.t / retract;
        var _hx = _ox + shield_pos.x + lengthdir_x(shield_r, shield_pos.dir), _hy = _oy + shield_pos.y + lengthdir_y(shield_r, shield_pos.dir);
        var _cx = lerp(_hx, _sx, _rk), _cy = lerp(_hy, _sy, _rk);
        draw_beam(_sx, _sy, _cx, _cy, laser_w * (1 - _rk), 1 - _rk, laser_col_glow, laser_col, laser_col_hot);
        draw_shield(_ox + shield_pos.x, _oy + shield_pos.y, shield_pos.dir, 1 - _rk);
    }
    else
    {
        var _fk = 1 - (fin.t - retract) / 20;
        gpu_set_blendmode(bm_add);
        draw_set_alpha(_fk);
        draw_circle_colour(_sx, _sy, 120 * (1.2 - _fk), c_white, c_black, false);
        draw_set_alpha(1);
        gpu_set_blendmode(bm_normal);
    }
}

// everyone going for it (slow motion): Susie, Ralsei & Pink leap; the rest fire from where they are
if (fin.st == "leap" || fin.st == "white")
{
    for (var i = 0; i < array_length(leap); i++)
    {
        var _l = leap[i];
        if (_l.stay)
        {
            var _yy = _l.y0 + ((_l.name == "Jevil") ? sin(t / 14) * 4 : 0);
            var _f = (_l[$ "anim"] == true) ? _l.f : 0;
			draw_sprite_ext(_l.spr, _f, _ox + _x, _oy + _y, _l.s, _l.s, 0, c_white, 1);
            continue;
        }
        var _x = lerp(_l.x0, _l.x1, _l.k), _y = lerp(_l.y0, _l.y1, _l.k) - _l.h * 4 * _l.k * (1 - _l.k);
        var _n = sprite_get_number(_l.spr);
        var _img = (variable_struct_exists(_l, "anim") && _l.anim) ? min(_n - 1, floor(_l.k * _n)) : 0;
        draw_sprite_ext(_l.spr, _img, _ox + _x, _oy + _y, _l.s, _l.s, 0, c_white, 1);
    }
    for (var i = 0; i < array_length(volley); i++)
    {
        var _v = volley[i];
        if (_v.delay > 0 || _v.k >= 1) continue;
        var _x = _ox + lerp(_v.x0, _v.x1, _v.k), _y = _oy + lerp(_v.y0, _v.y1, _v.k) - sin(_v.k * pi) * 60;
        if (_v.spr == -1)
        {
            gpu_set_blendmode(bm_add);
            draw_circle_colour(_x, _y, 18, _v.col, c_black, false);
            draw_circle_colour(_x, _y, 8, c_white, _v.col, false);
            gpu_set_blendmode(bm_normal);
        }
        else draw_sprite_ext(_v.spr, 0, _x, _y, 2, 2, _v.rot, c_white, 1);
    }
}

// little bursts (and the damage they took)
for (var i = 0; i < array_length(pops); i++)
{
    var _p = pops[i];
    var _n = sprite_get_number(_p.spr);
    if (_p.t < _n * 3) draw_sprite_ext(_p.spr, _p.t / 3, _ox + _p.x, _oy + _p.y, _p.s, _p.s, 0, c_white, 1);
    if (_p.txt != "")
    {
        draw_set_font(fnt_greaterdetermination);
        draw_set_halign(fa_center);
        draw_text_transformed_colour(_ox + _p.x, _oy + _p.y - 30 - _p.t * 0.6, _p.txt, 1, 1, 0, _p.col, _p.col, _p.col, _p.col, 1 - _p.t / 40);
        draw_set_halign(fa_left);
    }
}