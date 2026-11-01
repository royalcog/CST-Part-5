// a link of chain, wobbling like Deltarune's obj_chainpiece
var _link = function(_x, _y, _ang, _s, _col, _a)
{
    var _k = current_time / 1000 * 30 * 0.5 + _s;   // (DR: siner += 0.5 a frame at 30fps)
    draw_sprite_ext(spr_chainpiece, 0, _x + sin(_k / 4), _y + cos(_k / 4), 1 + sin(_k / 8) * 0.2, 1 + sin(_k / 8) * 0.2, _ang, _col, _a);
};
/// a straight chain from (_x1, _y1) to (_x2, _y2), a link every 10px
var _chain = function(_x1, _y1, _x2, _y2, _col, _link)
{
    var _d = point_distance(_x1, _y1, _x2, _y2), _ang = point_direction(_x1, _y1, _x2, _y2);
    for (var _l = 0; _l <= _d; _l += 10) _link(_x1 + lengthdir_x(_l, _ang), _y1 + lengthdir_y(_l, _ang), _ang, _l, _col, 1);
};

// ---- King's chain attack
if (wave != undefined)
{
    var _n = array_length(wave.pieces);
    for (var i = 0; i < _n; i++)
    {
        var _p = wave.pieces[i];
        var _ang = 180;
        if (i + 1 < _n) _ang = point_direction(_p.x0, _p.y, wave.pieces[i + 1].x0, wave.pieces[i + 1].y);
        _link(_p.x0, _p.y, _ang, _p.s, c_white, wave.fade);
    }
}

// ---- the chain reaching out to Susie / swinging her round (red, like obj_finalchain)
if (grab != undefined && instance_exists(obj_king) && instance_exists(obj_susie))
{
    var _sp = ssoul_pos();
    if (spin != undefined && spin.phase == "swing")
    {
        var _p = king_spin_pos();
        _chain(_p.x, _p.y, _sp.x, _sp.y, c_red, _link);
    }
    else
    {
        var _h = king_hand_pos();
        var _ang = point_direction(_h.x, _h.y, _sp.x, _sp.y);
        var _len = min(grab.len, point_distance(_h.x, _h.y, _sp.x, _sp.y));
        _chain(_h.x, _h.y, _h.x + lengthdir_x(_len, _ang), _h.y + lengthdir_y(_len, _ang), c_red, _link);
    }
}

// ---- afterimages behind Susie while she's swung round and thrown
if (spin != undefined && spin.phase != "gone")
{
    var _n = array_length(spin.trail);
    for (var i = 1; i < _n; i++)   // (0 is where she is now)
    {
        var _t = spin.trail[i];
        draw_sprite_ext(_t.spr, _t.img, _t.x, _t.y, _t.xs, _t.ys, _t.ang, c_white, 0.35 * (1 - i / _n));
    }
}

// ---- Susie's SOUL, once he's got hold of it
if (ssoul != undefined && instance_exists(obj_susie) && obj_susie.visible)
{
    var _sp = ssoul_pos();
    draw_sprite_ext(spr_soul_red, 0, _sp.x, _sp.y, ssoul.scale, ssoul.scale, 0, c_white, 1);
}

// ---- King's SOUL (a monster's: white, upside down), flashing after a hit
if (ksoul != undefined && ksoul.a > 0 && (ksoul.inv <= 0 || (ksoul.inv div 3) mod 2 == 0))
{
    gpu_set_fog(true, c_white, 0, 0);
    draw_sprite_ext(spr_soul_red, 0, ksoul.x, ksoul.y, 1, -1, 0, c_white, ksoul.a);
    gpu_set_fog(false, c_black, 0, 0);
}

// ---- Susie's axes (mirrored: she's throwing them right)
for (var i = 0; i < array_length(axes); i++)
{
    var _a = axes[i];
    draw_sprite_ext(spr_axe_bullet, 0, _a.x, _a.y, -axe_scale, axe_scale, _a.ang, c_white, _a.a);
}

// ---- Ralsei's fireshock (it points right as drawn: it's flying left)
if (fire != undefined)
{
    draw_sprite_ext(spr_plat_fireball, floor(fire.f) mod sprite_get_number(spr_plat_fireball), fire.x, fire.y,
        (fire.vx < 0 ? -1 : 1) * fire_scale, fire_scale, fire.parried ? fire.rot : 0, c_white, fire.a);
}