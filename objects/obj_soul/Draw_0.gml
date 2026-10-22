if (split_controlled) exit; // obj_knight_split_attack draws the pieces

// light blue grid inside the box
if (soul_mode == "lightblue" && !external_move && grid_alpha > 0.01 && instance_exists(obj_battlebox) && obj_battlebox.visible)
{
    var _b = scr_get_box_interior();
    draw_set_color(lightblue_color);
    draw_set_alpha(grid_alpha);
    for (var i = 1; i <= 2; i++)
    {
        var _gx = lerp(_b.x1, _b.x2, i / 3);
        var _gy = lerp(_b.y1, _b.y2, i / 3);
        var _p1 = scr_box_local_to_world(_gx, _b.y1), _p2 = scr_box_local_to_world(_gx, _b.y2);
        var _p3 = scr_box_local_to_world(_b.x1, _gy), _p4 = scr_box_local_to_world(_b.x2, _gy);
        draw_line_width(_p1.x, _p1.y, _p2.x, _p2.y, grid_line_w);
        draw_line_width(_p3.x, _p3.y, _p4.x, _p4.y, grid_line_w);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// green: the ring and the shield
if (soul_mode == "green")
{
    draw_set_color(green_color);
    draw_set_alpha(ring_alpha * shield_pop);
    draw_circle(round(x), round(y), shield_r, true);

    if (shield_on)
    {
        var _r = shield_r * (0.6 + 0.4 * shield_pop);
        var _arc = shield_arc * shield_pop;
        draw_set_color(shield_color);
        draw_set_alpha(shield_pop);
        var _steps = 6;
        for (var i = 0; i < _steps; i++)
        {
            var _a1 = shield_angle - _arc + (2 * _arc) * (i / _steps);
            var _a2 = shield_angle - _arc + (2 * _arc) * ((i + 1) / _steps);
            draw_line_width(x + lengthdir_x(_r, _a1), y + lengthdir_y(_r, _a1), x + lengthdir_x(_r, _a2), y + lengthdir_y(_r, _a2), shield_w);
        }
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}

var _tint = -1; // no sprite for this colour yet: the normal soul, flat-tinted
if (soul_mode == "lightblue" && lightblue_sprite == -1) _tint = lightblue_color;
if (soul_mode == "green"     && green_sprite     == -1) _tint = green_color;

if (_tint != -1)
{
    gpu_set_fog(true, _tint, 0, 1);
    draw_sprite_ext(sprite_index, image_index, round(x), round(y), image_xscale, image_yscale, image_angle, c_white, image_alpha);
    gpu_set_fog(false, c_black, 0, 0);
}
else
{
    draw_sprite_ext(sprite_index, image_index, round(x), round(y), image_xscale, image_yscale, image_angle, image_blend, image_alpha);
}