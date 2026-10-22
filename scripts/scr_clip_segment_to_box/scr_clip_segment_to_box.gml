/// @function scr_clip_segment_to_box(_x0, _y0, _x1, _y1, _xmin, _xmax, _ymin, _ymax)
/// @description Clips the line segment from (_x0,_y0) to (_x1,_y1) against an
/// axis-aligned box. Returns { t0, t1 } — the portion of the segment (as
/// fractions from 0 at the start point to 1 at the end point) that falls
/// inside the box — or undefined if the segment never enters the box at
/// all. Standard Liang-Barsky line clipping.
function scr_clip_segment_to_box(_x0, _y0, _x1, _y1, _xmin, _xmax, _ymin, _ymax)
{
    var _dx = _x1 - _x0;
    var _dy = _y1 - _y0;

    var _t0 = 0;
    var _t1 = 1;

    var _p = [-_dx, _dx, -_dy, _dy];
    var _q = [_x0 - _xmin, _xmax - _x0, _y0 - _ymin, _ymax - _y0];

    for (var _i = 0; _i < 4; _i++)
    {
        if (_p[_i] == 0)
        {
            if (_q[_i] < 0) return undefined;
        }
        else
        {
            var _r = _q[_i] / _p[_i];
            if (_p[_i] < 0)
            {
                if (_r > _t1) return undefined;
                if (_r > _t0) _t0 = _r;
            }
            else
            {
                if (_r < _t0) return undefined;
                if (_r < _t1) _t1 = _r;
            }
        }
    }

    if (_t0 > _t1) return undefined;
    return { t0: _t0, t1: _t1 };
}