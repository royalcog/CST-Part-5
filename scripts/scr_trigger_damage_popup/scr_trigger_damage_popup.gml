function scr_trigger_damage_popup(_target, _amount = 0, _color_top = c_white, _color_bottom = c_white, _x_offset = 0, _y_offset = -20, _sound = snd_hurt)
{
    if (!instance_exists(_target)) return noone;

    if (_sound != noone) audio_play_sound(_sound, 5, false);

    // spawn one depth-step in front of whatever it's attached to, so
    // it's always visible in front of that target specifically —
    // hardcoding this to a fixed depth meant it could end up drawn
    // behind targets whose own depth runs lower than that fixed value
    var _dmg = instance_create_depth(_target.x + _x_offset, _target.y + _y_offset, _target.depth - 1, obj_damage_number);
    _dmg.damage_amount = _amount;
    _dmg.color_top = _color_top;
    _dmg.color_bottom = _color_bottom;

    var _facing = scr_get_facing_dir(_target);
    var _bounce_dir = (_facing != 0) ? -_facing : choose(-1, 1); // opposite of facing, or random if unknown
    _dmg.x_vel = _bounce_dir * 2.5; // tune bounce strength here

    return _dmg;
}