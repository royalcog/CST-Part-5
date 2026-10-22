function scr_make_attack_data(_idle_spr, _anim_spr, _count, _frame_time, _offset_x, _offset_y, _damage, _col_top, _col_bottom, _spawn_func)
{
    return {
        idle_sprite: _idle_spr,
        anim_sprite: _anim_spr,
        max_count: _count,
        frame_time: _frame_time,
        offset_x: _offset_x,
        offset_y: _offset_y,
        damage_amount: _damage,
        color_top: _col_top,
        color_bottom: _col_bottom,
        spawn_func: _spawn_func
    };
}

function scr_start_attack(_attacker, _data)
{
    _attacker.attack_data = _data;
    _attacker.proj_thrown = 0;
    _attacker.attack_active = true;
}