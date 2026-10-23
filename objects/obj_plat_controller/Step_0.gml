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
var _dx = scr_plat_wrap_dx(fol_last.x, _e.x);
var _dy = _e.y - fol_last.y;
_f.x = _e.x;
_f.y = _e.y;
if (_f.face_hold > 0) _f.face_hold--;   // turned for dialogue: stays that way for a bit
else if (_dx != 0) _f.face = sign(_dx);
else if (_behind <= follow_delay && _e.g) _f.face = (scr_plat_wrap_dx(_f.x, _l.x) >= 0) ? 1 : -1;   // stood still: face whoever you're controlling
_f.grounded = _e.g;
_f.animate(_dx != 0, _e.g, _dy);
fol_last = { x: _e.x, y: _e.y };

// flowers (or any press_tiles) react to whoever's standing on them
update_pressed();

// --- Titan Spawn (once the halfway chat's done) ---
if (state == "play" && spawn_on)
{
    intro_t++;
    var _ld = leader();
    switch (intro)
    {
        case "spawn":   // the first one floats down from above, in front of you
            intro_spawn = spawn_titan(true);
            intro_spawn.scripted  = true;
            intro_spawn.hold_dist = intro_hold;
            intro = "arrive";
            intro_t = 0;
        break;

        case "arrive":   // once it's on screen: "Watch out!" from whoever you're controlling
            if (!instance_exists(intro_spawn)) { intro = "after"; intro_t = 0; break; }
            if (intro_spawn.appear_t >= intro_spawn.appear_len && intro_spawn.y > cam_y + 60 && !instance_exists(obj_textbox))
            {
                global.plat_lock = true;
                create_textbox("plat_watchout_" + _ld.who);
                intro = "talk";
                intro_t = 0;
            }
        break;

        case "talk":
            if (!instance_exists(obj_textbox)) { intro = "pause"; intro_t = 0; }
        break;

        case "pause":   // a beat, then they take it out in one hit
            if (intro_t >= intro_pause && _ld.grounded && !_ld.attacking)
            {
                if (instance_exists(intro_spawn)) intro_spawn.hp = 1;
                _ld.attack_cool = 0;
                _ld.start_attack();
                intro = "attack";
                intro_t = 0;
            }
        break;

        case "attack":
            if (!instance_exists(intro_spawn)) { intro = "after"; intro_t = 0; }
            else if (intro_t >= 150 && !_ld.attacking) { _ld.attack_cool = 0; _ld.start_attack(); intro_t = 0; }   // missed somehow: again
        break;

        case "after":   // a second later, the other one's "..."
            if (intro_t >= intro_after && !instance_exists(obj_textbox))
            {
                create_textbox("plat_dots_" + follower().who);
                intro = "dots";
                intro_t = 0;
            }
        break;

        case "dots":
            if (!instance_exists(obj_textbox))
            {
                global.plat_lock = false;
                intro   = "done";
                spawn_t = 0;
            }
        break;

        case "done":   // from here on, one every spawn_every frames
            spawn_t++;
            if (spawn_t >= spawn_every)
            {
                if (instance_number(obj_plat_titanspawn) < spawn_max) spawn_titan(irandom(2) == 0);
                spawn_t = 0;
            }
        break;
    }
}

// dialogue triggers (only once you're playing, and never over another textbox)
if (state == "play" && !instance_exists(obj_textbox))
{
    var _tr = trigger_hit();
    if (_tr != undefined)
    {
        _tr.done = true;
        create_textbox(_tr.text);
    }
}