function scr_get_box_interior(use_target = false)
{
    var _bb = obj_battlebox;
    var _pad_x = 15;
    var _border = 8;

    var _xscale = use_target ? _bb.target_scale_x : _bb.image_xscale;
    var _yscale = use_target ? _bb.target_scale_y : _bb.image_yscale;

    var _w = _bb.raw_width  * _xscale;
    var _h = _bb.raw_height * _yscale;
    var _pad_x_s    = _pad_x  * _xscale;
    var _border_x_s = _border * _xscale;
    var _border_y_s = _border * _yscale;

    var _bx = use_target
        ? _bb.box_base_x + (_bb.raw_width  - _bb.raw_width  * _xscale) / 2
        : _bb.x;
    var _by = use_target
        ? _bb.box_base_y + (_bb.raw_height - _bb.raw_height * _yscale) / 2
        : _bb.y;

    return {
        x1: _bx + _pad_x_s + _border_x_s,
        y1: _by + _border_y_s,
        x2: _bx + _w - _pad_x_s - _border_x_s,
        y2: _by + _h - _border_y_s
    };
}