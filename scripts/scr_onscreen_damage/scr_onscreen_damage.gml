function scr_show_damage(_obj, _amount, _color_top = c_white, _color_bottom = noone)
{
    if (!instance_exists(_obj)) exit;
    var _dmg = instance_create_depth(_obj.x, _obj.y - sprite_get_height(_obj.sprite_index) * _obj.image_yscale, _obj.depth - 1, obj_damage_number);
    _dmg.damage_amount = _amount;
    _dmg.color_top = _color_top;
    _dmg.color_bottom = (_color_bottom == noone) ? _color_top : _color_bottom; // solid color if bottom not given
}