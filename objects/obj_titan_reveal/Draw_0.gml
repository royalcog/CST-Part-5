// (Ch4's actor Draw, minus the battle states. every layer's drawn from the Titan's top-left corner)

// ---------------- wings shut: each layer sits 4px off centre, the body animates, the star circles
if (drawstate == "defense end")
{
    var _d = wobble_dist;
    // Ch4's offsets for each layer (its rotation2 is always 0, so these are fixed; only the star's go round)
    var _o = [
        [ _d,  _d], [-_d, -_d], [-_d,  _d], [-_d,  _d],    // layers 0-3
        [-_d, -_d], [ _d,  _d], [ _d, -_d],                // layers 5-7
    ];
    var _c = dcos(rotation - 270), _s = dsin(rotation - 270);
    var _sx = _c * _d + _s * _d;
    var _sy = -_s * _d + _c * _d;

    if (show_titan)
    {
        draw_tl(spr_cover_wings_defense_layer_0, 6, x + _o[0][0], y + _o[0][1]);
        draw_tl(spr_cover_wings_defense_layer_1, 6, x + _o[1][0], y + _o[1][1]);
        draw_tl(spr_cover_wings_defense_layer_2, 6, x + _o[2][0], y + _o[2][1]);
        draw_tl(spr_cover_wings_defense_layer_3, 6, x + _o[3][0], y + _o[3][1]);
        draw_tl(spr_cover_wings_defense_layer_4, siner, x, y);
        draw_tl(spr_titan_star_idle, siner, x + _sx, y + _sy);
        draw_tl(spr_cover_wings_defense_layer_5, 6, x + _o[4][0], y + _o[4][1]);
        draw_tl(spr_cover_wings_defense_layer_6, 6, x + _o[5][0], y + _o[5][1]);
        draw_tl(spr_cover_wings_defense_layer_7, 6, x + _o[6][0], y + _o[6][1]);
    }

    // the black square over it, then the crescent on top
    if (a_black > 0)
    {
        draw_set_colour(c_black);
        draw_set_alpha(a_black);
        draw_rectangle(x + black_x, y + black_y, x + black_x + black_size, y + black_y + black_size, false);
        draw_set_alpha(1);
        draw_set_colour(c_white);
    }
    if (a_crescent > 0)
        draw_tl(spr_titan_defense_highlight2, 0, x + _o[0][0] + crescent_dx, y + _o[0][1] + crescent_dy, a_crescent);
}

// ---------------- opening: the wings play backwards, each with two fading copies trailing behind
if (drawstate == "undefense" && show_titan && wing_t < 6)
{
    var _layers = [spr_cover_wings_defense_layer_0, spr_cover_wings_defense_layer_1, spr_cover_wings_defense_layer_2,
                   spr_cover_wings_defense_layer_3, spr_cover_wings_defense_layer_4, spr_titan_star_dissapear,
                   spr_cover_wings_defense_layer_5, spr_cover_wings_defense_layer_6, spr_cover_wings_defense_layer_7];
    var _i1 = max(0, wing_t - 2 / 3);
    var _i2 = wing_t - 1 / 3;
    for (var i = 0; i < array_length(_layers); i++) draw_tl(_layers[i], _i1, x, y, 1 / 3);
    if (_i2 > 0) for (var i = 0; i < array_length(_layers); i++) draw_tl(_layers[i], _i2, x, y, 2 / 3);
    for (var i = 0; i < array_length(_layers); i++)
        draw_tl(_layers[i], (_layers[i] == spr_titan_star_dissapear) ? 0 : wing_t, x, y);
}

// ---------------- open: the full Titan, idling
if (drawstate == "idle" && show_titan)
{
    draw_tl(spr_titan_0_backwing, siner, x, y);
    draw_tl(spr_titan_1_backwing, siner, x, y);
    draw_tl(spr_titan_2_backwing, siner, x, y);
    draw_tl(spr_titan_3_backwing, siner, x, y);
    draw_tl(spr_cover_wings_defense_layer_4, siner, x, y);
    draw_tl(spr_titan_star_dissapear, 0, x, y);
    draw_tl(spr_titan_5_backwing, siner, x, y);
    draw_tl(spr_titan_6_backwing, siner, x, y);
    draw_tl(spr_titan_7_backwing, siner, x, y);
}