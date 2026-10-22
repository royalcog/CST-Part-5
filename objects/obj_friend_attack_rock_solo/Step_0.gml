timer++;

switch (phase)
{
    case "flash_pair":
        sub_timer--;
        if (sub_timer <= 0)
        {
            frac_left  = random_range(0.15, 0.85);
            frac_right = random_range(0.15, 0.85);
            instance_create_depth(0, 0, -390, obj_strip_flash, { orientation: "horizontal", position_frac: frac_left,  blinks: 2 });
            instance_create_depth(0, 0, -390, obj_strip_flash, { orientation: "horizontal", position_frac: frac_right, blinks: 2 });
            phase = "flash_wait";
        }
    break;

    case "flash_wait":
        if (instance_number(obj_strip_flash) == 0)
        {
            var _bounds = scr_get_attack_bounds();

            var _left_perp = lerp(_bounds.y1, _bounds.y2, frac_left);
            var _lh = instance_create_depth(0, 0, -380, obj_friend_hand_punch, { side: "left", fixed_coord: _left_perp });
            _lh.sprite_index = spr_friend_hand_rock;

            var _right_perp = lerp(_bounds.y1, _bounds.y2, frac_right);
            var _rh = instance_create_depth(0, 0, -380, obj_friend_hand_punch, { side: "right", fixed_coord: _right_perp });
            _rh.sprite_index = spr_friend_hand_rock;

            phase = "punching_pair";
        }
    break;

    case "punching_pair":
        if (instance_number(obj_friend_hand_punch) == 0)
        {
            sub_timer = 15;
            phase = "flash_pair";
        }
    break;
}

if (timer >= duration)
{
    instance_destroy();
}