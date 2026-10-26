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