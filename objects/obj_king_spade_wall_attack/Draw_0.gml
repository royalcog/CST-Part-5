if (array_length(pending) == 0) exit;

var _in = scr_get_box_interior();
draw_set_color(warn_color);
draw_set_alpha(warn_alpha);

for (var i = 0; i < array_length(pending); i++)
{
    var _p = pending[i];
    if ((_p.timer div 5) mod 2 != 0) continue; // blink

    for (var k = 0; k < _p.n; k++)
    {
        if (k >= _p.gap && k < _p.gap + gap_size) continue; // the hole = where the gap will be

        var _a = k / _p.n;
        var _b = (k + 1) / _p.n;
        var _x1, _y1, _x2, _y2;

        if (_p.sideways)
        {
            _y1 = lerp(_in.y1, _in.y2, _a) + warn_inset;
            _y2 = lerp(_in.y1, _in.y2, _b) - warn_inset;
            _x1 = (_p.from == "left") ? _in.x1 : _in.x2 - warn_depth;
            _x2 = _x1 + warn_depth;
        }
        else
        {
            _x1 = lerp(_in.x1, _in.x2, _a) + warn_inset;
            _x2 = lerp(_in.x1, _in.x2, _b) - warn_inset;
            _y1 = (_p.from == "top") ? _in.y1 : _in.y2 - warn_depth;
            _y2 = _y1 + warn_depth;
        }

        draw_rectangle(round(_x1), round(_y1), round(_x2), round(_y2), false);
    }
}

draw_set_alpha(1);
draw_set_color(c_white);