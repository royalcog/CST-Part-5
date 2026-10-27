slide = lerp(slide, shown ? 1 : 0, slide_lerp);
if (!shown && slide < 0.01) slide = 0;

var _tp = global.tp;
shown_tp = lerp(shown_tp, _tp.value, 0.25);
if (abs(shown_tp - _tp.value) < 0.05) shown_tp = _tp.value;
_tp.flash = max(0, _tp.flash - 0.08);
_tp.grazing++;
_tp.fresh++;

// the graze shell sits just behind the soul
if (instance_exists(obj_soul)) depth = obj_soul.depth + 1;

// the pickup glow fades (Deltarune: 0.15 a frame at 30fps), the stars rise and slow down
glow = max(0, glow - 0.075);
for (var i = array_length(stars) - 1; i >= 0; i--)
{
    var _s = stars[i];
    _s.t++;
    var _k = _s.t / _s.dur;
    _s.y -= _s.spd * (1 - _k);
    _s.a  = lerp(1, 0.25, _k);
    _s.f += 5 / _s.dur;
    if (_s.t >= _s.dur) array_delete(stars, i, 1);
}