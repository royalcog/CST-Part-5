/// switches a soul between "red" (normal), "lightblue" (3x3 grid movement) and "green" (shield)
function scr_soul_set_mode(_soul, _mode)
{
    with (_soul)
    {
        soul_mode = _mode;
        sprite_index = base_sprite;
        if (_mode == "lightblue" && lightblue_sprite != -1) sprite_index = lightblue_sprite;
        if (_mode == "green"     && green_sprite     != -1) sprite_index = green_sprite;
        grid_c = 1;
        grid_r = 1;
        grid_buffer = -1;
    }
}

/// where the soul's current grid sector sits in the room
function scr_soul_grid_target(_b, _cw, _ch)
{
    var _lx = _b.x1 + (grid_c + 0.5) * _cw;
    var _ly = _b.y1 + (grid_r + 0.5) * _ch;
    if (instance_exists(obj_battlebox) && obj_battlebox.visible) return scr_box_local_to_world(_lx, _ly);
    return { x: _lx, y: _ly };
}

/// light blue movement (runs inside obj_soul): 3x3 sectors, 4 directions, glides between them
function scr_soul_grid_step()
{
    var _b  = scr_get_attack_bounds();
    var _cw = (_b.x2 - _b.x1) / 3;
    var _ch = (_b.y2 - _b.y1) / 3;

    // newest press wins, and a press mid-move is saved for when it arrives
    // (0 right, 1 up, 2 left, 3 down — on screen)
    if (keyboard_check_pressed(vk_right)) grid_buffer = 0;
    if (keyboard_check_pressed(vk_up))    grid_buffer = 1;
    if (keyboard_check_pressed(vk_left))  grid_buffer = 2;
    if (keyboard_check_pressed(vk_down))  grid_buffer = 3;

    var _t = scr_soul_grid_target(_b, _cw, _ch);

    if (point_distance(x, y, _t.x, _t.y) <= grid_ready_dist)
    {
        var _dir = grid_buffer;
        if (_dir == -1)
        {
            // nothing new pressed: keep going whichever way is still held
            if      (keyboard_check(vk_right)) _dir = 0;
            else if (keyboard_check(vk_up))    _dir = 1;
            else if (keyboard_check(vk_left))  _dir = 2;
            else if (keyboard_check(vk_down))  _dir = 3;
        }
        grid_buffer = -1;

        if (_dir != -1)
        {
            // the box may be turned: convert the screen direction into the grid's own
            var _turns = 0;
            if (instance_exists(obj_battlebox)) _turns = ((round(obj_battlebox.box_angle / 90) mod 4) + 4) mod 4;
            _dir = ((_dir - _turns) mod 4 + 4) mod 4;

            var _nc = clamp(grid_c + (_dir == 0) - (_dir == 2), 0, 2);
            var _nr = clamp(grid_r + (_dir == 3) - (_dir == 1), 0, 2);
            if (!grid_blocked[_nc + _nr * 3]) { grid_c = _nc; grid_r = _nr; } // can't go into a broken sector
            _t = scr_soul_grid_target(_b, _cw, _ch);
        }
    }

    x = lerp(x, _t.x, grid_lerp);
    y = lerp(y, _t.y, grid_lerp);

    // grid brightens while it's moving, fades back down when it settles
    var _moving = point_distance(x, y, _t.x, _t.y) > 0.5;
    grid_alpha = lerp(grid_alpha, _moving ? grid_alpha_moving : grid_alpha_idle, 0.15);

    if (!_moving) { x = _t.x; y = _t.y; }
}

/// green movement (runs inside obj_soul): stays in the middle of the box, arrow keys turn the shield
function scr_soul_green_step()
{
    var _c = scr_box_center();
    x = _c.x;
    y = _c.y;

    var _step = 90;
    if (shield_dirs == 8)
    {
        // 8 directions (0 right, 1 up-right, 2 up ... 7 down-right): hold two arrows for a diagonal.
        // only a new press changes it, so letting go of one key of a diagonal doesn't snap it back
        _step = 45;
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(vk_up)
            || keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_down))
        {
            var _hx = keyboard_check(vk_right) - keyboard_check(vk_left);
            var _vy = keyboard_check(vk_down) - keyboard_check(vk_up);
            if (_hx != 0 || _vy != 0) shield_dir = round(point_direction(0, 0, _hx, _vy) / 45) mod 8;
        }
    }
    else
    {
        // newest press wins (0 right, 1 up, 2 left, 3 down)
        if (keyboard_check_pressed(vk_right)) shield_dir = 0;
        if (keyboard_check_pressed(vk_up))    shield_dir = 1;
        if (keyboard_check_pressed(vk_left))  shield_dir = 2;
        if (keyboard_check_pressed(vk_down))  shield_dir = 3;
    }

    shield_angle += angle_difference(shield_dir * _step, shield_angle) * shield_turn;
    if (shield_on) shield_pop = min(shield_pop + 0.1, 1);
}