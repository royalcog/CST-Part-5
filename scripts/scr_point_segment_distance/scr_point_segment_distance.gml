/// @function scr_point_segment_distance(_px, _py, _ax, _ay, _bx, _by)
/// @description Shortest distance from point (_px,_py) to the line segment
/// running from (_ax,_ay) to (_bx,_by). Standard point-to-segment projection.
function scr_point_segment_distance(_px, _py, _ax, _ay, _bx, _by)
{
    var _abx = _bx - _ax;
    var _aby = _by - _ay;
    var _apx = _px - _ax;
    var _apy = _py - _ay;

    var _len_sq = _abx * _abx + _aby * _aby;
    var _t = (_len_sq > 0) ? clamp((_apx * _abx + _apy * _aby) / _len_sq, 0, 1) : 0;

    var _closest_x = _ax + _t * _abx;
    var _closest_y = _ay + _t * _aby;

    return point_distance(_px, _py, _closest_x, _closest_y);
}