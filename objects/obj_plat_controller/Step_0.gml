t++;

switch (state)
{
    case "fadein":
        if (instance_exists(obj_cutscenefade)) t = 0;
        if (t >= intro_wait)
        {
            create_textbox("self_5");
            state = "talk";
        }
    break;
}

// --- swapping ---
if (swap_cool > 0) swap_cool--;
if (!global.plat_lock && swap_cool <= 0 && keyboard_check_pressed(swap_key)) swap();

// --- the trail: a new step every time the one you control moves ---
var _l = leader();
var _last = hist[array_length(hist) - 1];
if (point_distance(_l.x, _l.y, _last.x, _last.y) >= 1)
    array_push(hist, { x: _l.x, y: _l.y, g: _l.grounded, f: _l.face });
if (array_length(hist) > hist_max)
{
    var _cut = array_length(hist) - hist_max;
    array_delete(hist, 0, _cut);
    fi = max(0, fi - _cut);
}

// --- the follower walks the trail ---
var _f = follower();
var _end = array_length(hist) - 1;
var _behind = _end - fi;
// keep going if they're too far back, or if they'd otherwise stop in mid-air
if (_behind > follow_delay || (!hist[fi].g && fi < _end)) fi++;
if (_end - fi > follow_delay + catch_up) fi++;
fi = min(fi, _end);

var _e = hist[fi];
var _dx = _e.x - fol_last.x;
var _dy = _e.y - fol_last.y;
_f.x = _e.x;
_f.y = _e.y;
if (_dx != 0) _f.face = sign(_dx);
else if (_behind <= follow_delay && _e.g) _f.face = _l.x >= _f.x ? 1 : -1;   // stood still: face whoever you're controlling
_f.grounded = _e.g;
_f.animate(_dx != 0, _e.g, _dy);
fol_last = { x: _e.x, y: _e.y };

// flowers (or any press_tiles) react to whoever's standing on them
update_pressed();

// dialogue triggers (only once you're playing, and not over another textbox)
if (state == "play" && !instance_exists(obj_textbox))
{
    var _tr = trigger_hit();
    if (_tr != undefined)
    {
        _tr.done = true;
        create_textbox(_tr.text);
    }
}