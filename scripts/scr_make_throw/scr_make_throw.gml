function scr_make_throw(_source_obj, _proj_sprite, _damage, _col_top, _col_bottom, _animate = true, _extra = undefined)
{
    var _t = {
        source_obj: _source_obj,
        proj_sprite: _proj_sprite,
        mode: "arc",
        damage_amount: _damage,
        color_top: _col_top,
        color_bottom: _col_bottom,
        animate: _animate,

        travel_time: 40,
        arc_height: 100,

        direction: "left",
        move_speed: 8,
        offscreen_margin: 60,

        spin_speed: 14,
        hit_radius: 16,
        impact_sound: noone,

        scale: 1,

        spawn_offset_x: 0,
        spawn_offset_y: -20,

        after_obj: noone,
        after_sprite: -1,
        after_at: "target",

        travel_sound: noone,
        travel_sound_gap: 30,

        pre_delay: 0,
        anticipation_frames: 12,
        throw_poof: noone,
		
		beep_flash_sprite: noone,
		beep_flash_duration: 10,
		
		depth_switch_frac: 0.75,
    };

    if (!is_undefined(_extra))
    {
        var _names = variable_struct_get_names(_extra);
        for (var i = 0; i < array_length(_names); i++)
        {
            variable_struct_set(_t, _names[i], variable_struct_get(_extra, _names[i]));
        }
    }

    return _t;
}