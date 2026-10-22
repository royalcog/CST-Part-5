hdir = keyboard_check(vk_right) - keyboard_check(vk_left);
vdir = keyboard_check(vk_down) - keyboard_check(vk_up);

if (!split_controlled && !external_move)
{
        if (soul_mode == "lightblue")
    {
        scr_soul_grid_step();
    }
    else if (soul_mode == "green")
    {
        scr_soul_green_step();
    }
    else
    {
        x += hdir * move_speed;
        y += vdir * move_speed;

        var _interior = scr_get_attack_bounds();
        var _soul_margin_x = sprite_width / 2;
        var _soul_margin_y = sprite_height / 2;

        var _min_x = _interior.x1 + _soul_margin_x;
        var _max_x = _interior.x2 - _soul_margin_x;
        var _min_y = _interior.y1 + _soul_margin_y;
        var _max_y = _interior.y2 - _soul_margin_y;

        if (_min_x > _max_x) { var _mid_x = (_min_x + _max_x) / 2; _min_x = _mid_x; _max_x = _mid_x; }
        if (_min_y > _max_y) { var _mid_y = (_min_y + _max_y) / 2; _min_y = _mid_y; _max_y = _mid_y; }

        var _local = scr_world_to_box_local(x, y);
        var _wall_local_x = clamp(_local.x, _min_x, _max_x);
        var _wall_local_y = clamp(_local.y, _min_y, _max_y);
        var _wall_world = scr_box_local_to_world(_wall_local_x, _wall_local_y);

        var _push_speed = move_speed * 2;
        x += clamp(_wall_world.x - x, -_push_speed, _push_speed);
        y += clamp(_wall_world.y - y, -_push_speed, _push_speed);
    }
}

if (swap_grace > 0) swap_grace--;

if (invulnerable)
{
    invuln_timer--;
    flash_timer--;
    if (flash_timer <= 0)
    {
        flash_visible = !flash_visible;
        flash_timer = flash_interval;
    }

    if (invuln_timer <= 0)
    {
        invulnerable = false;
        flash_visible = true;
    }
}
else
{
    flash_visible = true;
}

image_blend = c_white;
image_alpha = flash_visible ? 1 : 0;