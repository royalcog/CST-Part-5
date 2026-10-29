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

    // the shut wings, then (while it's hidden) the same shapes in black over them. Ch4 used a black square
    // here, but over the cloud sea the square's edges showed: a silhouette hides exactly the Titan and nothing else
    var _l = [
        [spr_cover_wings_defense_layer_0, 6, _o[0][0], _o[0][1]],
        [spr_cover_wings_defense_layer_1, 6, _o[1][0], _o[1][1]],
        [spr_cover_wings_defense_layer_2, 6, _o[2][0], _o[2][1]],
        [spr_cover_wings_defense_layer_3, 6, _o[3][0], _o[3][1]],
        [spr_cover_wings_defense_layer_4, siner, 0, 0],
        [spr_titan_star_idle, siner, _sx, _sy],
        [spr_cover_wings_defense_layer_5, 6, _o[4][0], _o[4][1]],
        [spr_cover_wings_defense_layer_6, 6, _o[5][0], _o[5][1]],
        [spr_cover_wings_defense_layer_7, 6, _o[6][0], _o[6][1]],
    ];
    if (show_titan)
        for (var i = 0; i < array_length(_l); i++) { var _e = _l[i]; draw_tl(_e[0], _e[1], x + _e[2], y + _e[3]); }
    if (a_black > 0)
        for (var i = 0; i < array_length(_l); i++) { var _e = _l[i]; draw_tl_black(_e[0], _e[1], x + _e[2], y + _e[3], a_black); }

    // the crescent on top
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

// ---------------- the cloud sea's puffs along its bottom edge, again, in front of it (drawn exactly the way
// obj_plat_cloud draws them, so they sit right on top of themselves)
if (instance_exists(cloud_sea))
{
    var _tc = current_time;
    with (cloud_sea)
    {
        for (var i = 0; i < array_length(other.cloud_puffs); i++)
        {
            var _p  = other.cloud_puffs[i];
            var _px = _p.x + sin(_tc / 500 + _p.base_angle) * bob_x;
            var _py = _p.y + sin(_tc / 250 + _p.base_angle * 0.05) * bob_y;
            if (outline && spr_puff_ol != -1)
                draw_sprite_ext(spr_puff_ol, _p.img mod sprite_get_number(spr_puff_ol), _px, _py - 1, _p.sc, _p.sc, 0, _p.col, 1);
            draw_sprite_ext(spr_puff, _p.img, _px, _py, _p.sc, _p.sc, 0, _p.col, 1);
        }
    }
}