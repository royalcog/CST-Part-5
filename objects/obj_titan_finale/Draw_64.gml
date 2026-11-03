var _gw = display_get_gui_width(), _gh = display_get_gui_height();
var _gs = _gw / vw;

// ---------------------------------------------------------------- the Petal Feather, over Susie's fist (the intro)
if (phase == "intro" && feather.on && instance_exists(obj_susie))
{
    var _su = instance_find(obj_susie, 0);
    var _k  = min(1, feather.t / feather_rise);
    var _fx = _su.x + (feather_fist.x - sprite_get_xoffset(_su.sprite_index)) * _su.image_xscale;
    var _fy = _su.y + (feather_fist.y - sprite_get_yoffset(_su.sprite_index)) * _su.image_yscale - feather_lift * (1 - (1 - _k) * (1 - _k));
    var _gx = (_fx - camera_get_view_x(view_camera[0])) * _gs, _gy = (_fy - camera_get_view_y(view_camera[0])) * _gs;
    gpu_set_blendmode(bm_add);
    draw_set_alpha(_k * (0.35 + 0.15 * sin(t * 0.12)));
    draw_circle_colour(_gx, _gy, 26 * _gs, c_white, c_black, false);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
    draw_sprite_ext(spr_petal_feather, 0, _gx, _gy, 2 * _gs, 2 * _gs, 0, c_white, _k);
}

// ---------------------------------------------------------------- Susie's & Ralsei's HP (the run)
if (phase != "intro" && fin.st != "leap" && fin.st != "white" && fin.st != "black" && fin.st != "damage" && fin.st != "done")
{
    draw_set_font(fnt_determination);
    var _names = ["Susie", "Ralsei"];
    for (var i = 0; i < 2; i++)
    {
        var _n  = _names[i];
        var _bx = 16 + i * 170, _by = 12;
        draw_set_colour(c_black);
        draw_rectangle(_bx, _by, _bx + 160, _by + 30, false);
        draw_set_colour(dmg_cols[$ _n]);
        draw_rectangle(_bx, _by, _bx + 160, _by + 30, true);
        draw_text(_bx + 6, _by + 4, string_upper(_n));
        draw_set_colour(make_colour_rgb(128, 0, 0));
        draw_rectangle(_bx + 76, _by + 11, _bx + 152, _by + 19, false);
        draw_set_colour(dmg_cols[$ _n]);
        draw_rectangle(_bx + 76, _by + 11, _bx + 76 + 76 * hp[$ _n] / max_hp[$ _n], _by + 19, false);
    }
    draw_set_colour(c_white);
}

// ---------------------------------------------------------------- the PRESS box, in the middle (mash Z)
if (box_k > 0)
{
    var _w = 260, _h = 56 * box_k;
    var _bx = _gw / 2 - _w / 2, _by = _gh / 2 - _h / 2;
    draw_set_colour(c_black);
    draw_rectangle(_bx, _by, _bx + _w, _by + _h, false);
    draw_set_colour(c_white);
    draw_rectangle(_bx, _by, _bx + _w, _by + _h, true);
    draw_rectangle(_bx + 1, _by + 1, _bx + _w - 1, _by + _h - 1, true);
    if (box_k >= 1)
    {
        draw_set_font(fnt_determination);
        draw_text(_bx + 12, _by + 6, "PRESS");
        var _blink = ((t div 8) mod 2 == 0);
        draw_set_colour(_blink ? c_yellow : c_white);
        draw_rectangle(_bx + 16, _by + 26, _bx + 40, _by + 48, true);
        draw_text(_bx + 22, _by + 28, "Z");
        // the bar
        var _x0 = _bx + 90, _x1 = _bx + _w - 14;
        draw_set_colour(make_colour_rgb(40, 40, 60));
        draw_rectangle(_x0, _by + 18, _x1, _by + 38, false);
        draw_set_colour(parry_col);
        draw_rectangle(_x0, _by + 18, lerp(_x0, _x1, press_k), _by + 38, false);
        draw_set_colour(c_white);
        draw_rectangle(_x0, _by + 18, _x1, _by + 38, true);
        draw_rectangle(lerp(_x0, _x1, press_k) - 1, _by + 14, lerp(_x0, _x1, press_k) + 1, _by + 42, false);
    }
    draw_set_colour(c_white);
}

// ---------------------------------------------------------------- white, then black, then the damage
if (white.a > 0)
{
    draw_set_alpha(white.a);
    draw_set_colour(c_white);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);
}
if (black > 0)
{
    draw_set_alpha(black);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}
if (array_length(dmg_list) > 0)
{
    draw_set_font(fnt_greaterdetermination);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    for (var i = 0; i < array_length(dmg_list); i++)
    {
        var _d = dmg_list[i];
        if (_d.t < 0) continue;
        var _pop = 1 + 0.8 * max(0, 1 - _d.t / 10);
        var _up  = max(0, 1 - _d.t / 14) * 16;
        var _col = dmg_cols[$ _d.name];
        draw_text_transformed_colour(_gw / 2 + _d.x, _gh / 2 + _d.y - _up, string(_d.amount), 2 * _pop, 2 * _pop, 0, _col, _col, c_white, c_white, 1);
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}