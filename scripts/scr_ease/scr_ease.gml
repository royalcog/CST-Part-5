/// @func scr_ease(_t, _type)
/// @param _t     progress 0..1
/// @param _type  "linear", "in", "out", "inout", "smooth", "back", "brake"
function scr_ease(_t, _type)
{
    _t = clamp(_t, 0, 1);
    switch (_type)
    {
        case "in":     return _t * _t * _t;
        case "out":    return 1 - power(1 - _t, 3);
        case "inout":  return (_t < 0.5) ? 4 * _t * _t * _t
                                         : 1 - power(-2 * _t + 2, 3) / 2;
        case "smooth": return _t * _t * (3 - 2 * _t);
        case "back":
            var _c1 = 1.70158;
            var _c3 = _c1 + 1;
            return 1 + _c3 * power(_t - 1, 3) + _c1 * power(_t - 1, 2);

        case "brake":
            // full speed until _p of the way through the time, then brakes to a stop
            var _p = 0.8;                  // fraction of the duration spent at full speed
            var _v = 2 / (1 + _p);         // top speed needed to still land exactly on target
            if (_t < _p) return _v * _t;
            var _u = _t - _p;
            return _v * _p + _v * _u - _v * _u * _u / (2 * (1 - _p));

        default:       return _t;
    }
}