// TP (Tension Points), the way Deltarune does it: one shared bar for the whole party, 0-100%.
// it fills from grazing bullets and DEFENDing, and spells/ACTs spend it.
// "darkness" (the Titan Spawn fight, like Deltarune's Ch4 darkness battles): the bar goes blue and you gain much less.
//
//  scr_tp_reset(_dark)          start of a battle: 0%, and whether it's a darkness fight
//  scr_tp_add(_pct)             gain (items etc. ignore darkness: pass _ignore_dark = true)
//  scr_tp_can_spend(_pct) / scr_tp_spend(_pct)
//  scr_tp_defend(_chars)        DEFEND: 16% each (2% each in darkness)
//  scr_graze(_x, _y, _r, _points, _key)   call every step from a bullet (see below)
//  scr_tp_bar_show(_on)         slide the bar in / out

function scr_tp_init()
{
    if (variable_global_exists("tp") && is_struct(global.tp)) return;
    global.tp = {
        value: 0,            // 0-100
        dark: false,
        // tuning
        defend_gain:      16,
        defend_gain_dark: 2,
        graze_mult_dark:  0.25,   // Deltarune sets most bullets' graze points to 0 in darkness. this keeps a little
        graze_radius:     28,     // px past a bullet's own radius that counts as a graze (soul's at 2x)
        graze_tick_div:   30,     // while still grazing, you get _points / this every frame (Deltarune's 1/30)
        // state
        grazing:   0,             // frames since the last graze (the shell fades out from this)
        grazed:    ds_map_create(), // bullets that have already given their first graze
        flash:     0              // the bar flashes white when you gain
    };
}

/// start of a battle
function scr_tp_reset(_dark = false)
{
    scr_tp_init();
    global.tp.value = 0;
    global.tp.dark  = _dark;
    global.tp.grazing = 999;
    ds_map_clear(global.tp.grazed);
}

function scr_tp_get() { scr_tp_init(); return global.tp.value; }

/// gain _pct TP. darkness doesn't change it here (DEFEND and grazing apply their own darkness amounts)
function scr_tp_add(_pct)
{
    scr_tp_init();
    var _before = global.tp.value;
    global.tp.value = clamp(global.tp.value + _pct, 0, 100);
    if (global.tp.value > _before) global.tp.flash = 1;
}

function scr_tp_can_spend(_pct) { scr_tp_init(); return global.tp.value >= _pct; }

/// spend _pct TP. false (and nothing spent) if there isn't enough
function scr_tp_spend(_pct)
{
    scr_tp_init();
    if (global.tp.value < _pct) return false;
    global.tp.value -= _pct;
    return true;
}

/// DEFEND: _chars party members defending this turn
function scr_tp_defend(_chars = 1)
{
    scr_tp_init();
    scr_tp_add(_chars * (global.tp.dark ? global.tp.defend_gain_dark : global.tp.defend_gain));
}

/// call every step from a bullet. (_x, _y) its centre, _r its hit radius, _points the % it gives the first time
/// it comes into graze range (then _points / 30 a frame while it stays there). _key: something unique to this
/// bullet (its id), so it only gives the first chunk once. no TP while the soul's invulnerable after a hit.
function scr_graze(_x, _y, _r, _points = 2, _key = id)
{
    scr_tp_init();
    if (!instance_exists(obj_soul)) return;
    var _s = instance_find(obj_soul, 0);
    if (_s.invulnerable) return;
    var _d = point_distance(_x, _y, _s.x, _s.y);
    if (_d > _r + global.tp.graze_radius) return;

    var _mult = global.tp.dark ? global.tp.graze_mult_dark : 1;
    var _k = string(_key);
    if (!ds_map_exists(global.tp.grazed, _k))
    {
        ds_map_add(global.tp.grazed, _k, true);
        scr_tp_add(_points * _mult);
        audio_play_sound(scr_graze_sound(), 1, false, 0.6);
    }
    else scr_tp_add(_points * _mult / global.tp.graze_tick_div);
    global.tp.grazing = 0;
}

/// the graze sound (a quiet tick if there isn't one ripped yet)
function scr_graze_sound()
{
    var _s = asset_get_index("snd_graze");
    return (_s != -1) ? _s : snd_select;
}

/// slide the TP bar in (true) or out (false). makes it if it isn't there
function scr_tp_bar_show(_on = true)
{
    scr_tp_init();
    if (!instance_exists(obj_tp_bar)) instance_create_depth(0, 0, -100, obj_tp_bar);
    with (obj_tp_bar) shown = _on;
}