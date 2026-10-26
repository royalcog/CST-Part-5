// "sea": the puffs, bobbing
if (mode == "sea")
{
    if (spr_puff == -1) exit;
    var _t = current_time;
    for (var i = 0; i < array_length(puffs); i++)
    {
        var _p = puffs[i];
        var _px = _p.x + sin(_t / 500 + _p.base_angle) * bob_x;
        var _py = _p.y + sin(_t / 250 + _p.base_angle * 0.05) * bob_y;
        if (outline && spr_puff_ol != -1)
            draw_sprite_ext(spr_puff_ol, _p.img mod sprite_get_number(spr_puff_ol), _px, _py - 1, _p.sc, _p.sc, 0, _p.col, 1);
        draw_sprite_ext(spr_puff, _p.img, _px, _py, _p.sc, _p.sc, 0, _p.col, 1);
    }
    exit;
}

// "rise": obj_plat_controller's Post Draw draws it around the bent tower. only when the tower's flat does it draw here
var _ctl = instance_find(obj_plat_controller, 0);
if (_ctl != noone && _ctl.wrap_on) exit;
var _cx = camera_get_view_x(view_camera[0]), _cy = camera_get_view_y(view_camera[0]);
draw_pass(false, _cx, _cy, 1);
draw_pass(true,  _cx, _cy, 1);