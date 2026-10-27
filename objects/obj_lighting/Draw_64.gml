var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

if (!surface_exists(light_surface))
{
    light_surface = surface_create(_gui_w, _gui_h);
}

surface_set_target(light_surface);

// CRITICAL FIX: Clear surface every frame so alpha rendering works properly
draw_clear_alpha(c_black, 0);

var _mid_x = _gui_w / 2;

// Draw left darkness
if (darkness_alpha_left > 0)
{
    draw_set_alpha(darkness_alpha_left);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _mid_x, _gui_h, false);
}

// Draw right darkness
if (darkness_alpha_right > 0)
{
    draw_set_alpha(darkness_alpha_right);
    draw_set_color(c_black);
    draw_rectangle(_mid_x, 0, _gui_w, _gui_h, false);
}

draw_set_alpha(1);
gpu_set_blendmode(bm_subtract);

var _vx = camera_get_view_x(view_camera[0]);
var _vy = camera_get_view_y(view_camera[0]);
var _vw = camera_get_view_width(view_camera[0]);
var _scale_x = _gui_w / _vw;
var _scale_y = _gui_h / camera_get_view_height(view_camera[0]);

// Draw light source cutouts
for (var i = 0; i < array_length(lights); i++)
{
    var _l = lights[i];
    // scr_room_to_gui is rotation-aware, so each character's light glow
    // (Pink included) stays centered on them even while the camera is
    // rotated, e.g. during a screen-flip attack
    var _p = scr_room_to_gui(_l.x, _l.y);
    var _lx = _p.x;
    var _ly = _p.y;
    var _r = _l.radius * _p.sx;

    var _steps = 16;
    for (var j = _steps; j > 0; j--)
    {
        var _t = j / _steps;
        draw_set_alpha(power(1 - _t, 2) * _l.strength);
        draw_circle(_lx, _ly, _r * _t, false);
    }
}

// Full-brightness cutouts for battlebox, UI, and hammers
if (instance_exists(obj_battlebox) && obj_battlebox.visible)
{
    with (obj_battlebox)
    {
        var _c = scr_box_center();
        var _half_w = (raw_width  * image_xscale) / 2;
        var _half_h = (raw_height * image_yscale) / 2;
        var _off = scr_rotate_point(-_half_w, -_half_h, box_angle);
        var _draw_x = _c.x + _off.x;
        var _draw_y = _c.y + _off.y;

        // scr_room_to_gui is rotation-aware (accounts for the camera's own
        // current view angle, e.g. during a screen-flip attack) — using it
        // here instead of a separate inline vx/vy/scale calculation keeps
        // this cutout lined up with the box no matter what the camera is
        // doing, the same way the box itself always stays lined up with it
        var _p = scr_room_to_gui(_draw_x, _draw_y);
                var _p = scr_room_to_gui(_draw_x, _draw_y);
        if (split_axis != "none")
        {
            var _k = (split_axis == "h") ? _p.sx : _p.sy;
            scr_draw_box_split(sprite_index, image_index, _p.x, _p.y, image_xscale * _p.sx, image_yscale * _p.sy, split_axis, split_off_a * _k, split_off_b * _k, c_white, 1);
        }
        else
        {
            draw_sprite_ext(sprite_index, image_index, _p.x, _p.y, image_xscale * _p.sx, image_yscale * _p.sy, box_angle + _p.angle, c_white, 1);
        }
    }
}

with (obj_hammer)
{
    var _sx = (x - _vx) * _scale_x;
    var _sy = (y - _vy) * _scale_y;
    draw_sprite_ext(sprite_index, image_index, _sx, _sy, image_xscale * _scale_x, image_yscale * _scale_y, image_angle, c_white, 1);
}

if (variable_global_exists("fight_attack_active") && global.fight_attack_active)
{
    if (instance_exists(obj_UI))
    {
        with (obj_UI)
        {
            var _sx = (x - _vx) * _scale_x;
            var _sy = (y - _vy) * _scale_y;
            draw_sprite_ext(sprite_index, image_index, _sx, _sy, image_xscale * _scale_x, image_yscale * _scale_y, image_angle, c_white, 1);
        }
    }
}

with (obj_giant_hammer)
{
    var _sx = (x - _vx) * _scale_x;
    var _sy = (y - _vy) * _scale_y;
    draw_sprite_ext(sprite_index, image_index, _sx, _sy, image_xscale * _scale_x, image_yscale * _scale_y, image_angle, c_white, 1);
}

with (obj_falling_hammer)
{
    var _sx = (x - _vx) * _scale_x;
    var _sy = (y - _vy) * _scale_y;
    draw_sprite_ext(sprite_index, image_index, _sx, _sy, image_xscale * _scale_x, image_yscale * _scale_y, image_angle, c_white, 1);
}

with (obj_soj_hit_hammer)
{
    var _sx = (x - _vx) * _scale_x;
    var _sy = (y - _vy) * _scale_y;
    draw_sprite_ext(sprite_index, image_index, _sx, _sy, image_xscale * _scale_x, image_yscale * _scale_y, image_angle, c_white, 1);
}

with (obj_gavel_hammer)
{
    var _sx = (x - _vx) * _scale_x;
    var _sy = (y - _vy) * _scale_y;
    draw_sprite_ext(sprite_index, image_index, _sx, _sy, image_xscale * _scale_x, image_yscale * _scale_y, image_angle, c_white, 1);
}

with (obj_bar_int)
{
    var _sx = (x - _vx) * _scale_x;
    var _sy = (y - _vy) * _scale_y;
    draw_sprite_ext(sprite_index, image_index, _sx, _sy, image_xscale * _scale_x, image_yscale * _scale_y, image_angle, c_white, 1);
}

with (obj_rotate_hand)
{
    var _p = scr_room_to_gui(x, y);
    draw_sprite_ext(sprite_index, image_index, _p.x, _p.y, image_xscale * _p.sx, image_yscale * _p.sy, image_angle + _p.angle, image_blend, image_alpha);
}

with (obj_friend_hand_punch)
{
    var _p = scr_room_to_gui(x, y);
    draw_sprite_ext(sprite_index, image_index, _p.x, _p.y, image_xscale * _p.sx, image_yscale * _p.sy, image_angle + _p.angle, image_blend, image_alpha);
}

with (obj_friend_hand_gun)
{
    var _p = scr_room_to_gui(x, y);
    draw_sprite_ext(sprite_index, image_index, _p.x, _p.y, image_xscale * _p.sx, image_yscale * _p.sy, image_angle + _p.angle, image_blend, image_alpha);
}

with (obj_friend_bullet)
{
    var _p = scr_room_to_gui(x, y);

    if (phase == "travel")
    {
        draw_set_alpha(1);
        draw_set_color(bullet_color);
        draw_circle(_p.x, _p.y, bullet_radius * _p.sx, false);

        var _pt = scr_room_to_gui(target_x, target_y);
        draw_set_alpha(0.6);
        draw_circle(_pt.x, _pt.y, (bullet_radius + 4) * _p.sx, true);
        draw_set_alpha(1);
    }
    else if (phase == "blink")
    {
        if (blink_visible)
        {
            draw_set_color(c_red);
            draw_circle(_p.x, _p.y, (bullet_radius + 2) * _p.sx, false);
        }
    }
}
draw_set_color(c_white);

with (obj_friend_shrapnel)
{
    var _p = scr_room_to_gui(x, y);
    draw_set_color(shrapnel_color);
    draw_circle(_p.x, _p.y, shrapnel_radius * _p.sx, false);
}
draw_set_color(c_white);

if (instance_exists(obj_soul) && obj_soul.image_alpha > 0)
{
    with (obj_soul)
    {
        var _p = scr_room_to_gui(round(x), round(y));
        draw_sprite_ext(sprite_index, image_index, _p.x, _p.y, image_xscale * _p.sx, image_yscale * _p.sy, image_angle + _p.angle, image_blend, image_alpha);
    }
}

with (obj_damage_number)
{
    var _p = scr_room_to_gui(x + x_offset, y + y_offset);

    draw_set_font(fnt_greaterdetermination);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text_transformed_color(_p.x, _p.y, string(damage_amount), scale * _p.sx, scale * _p.sy, _p.angle,
        color_top, color_top, color_bottom, color_bottom, alpha);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// Reset settings
draw_set_alpha(1);
gpu_set_blendmode(bm_normal);
surface_reset_target();

// Draw surface over the GUI layer
draw_surface(light_surface, 0, 0);