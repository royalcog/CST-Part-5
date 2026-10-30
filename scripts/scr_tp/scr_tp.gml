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
        graze_mult_dark:  0,      // Deltarune sets most bullets' graze points to 0 in darkness fights (so: none). raise it to allow some
        graze_radius:     28,     // px past a bullet's own radius that counts as a graze (soul's at 2x)
        graze_tick_div:   30,     // while still grazing, you get _points / this every frame (Deltarune's 1/30)
        // state
        grazing:   999,           // frames since the last graze (the shell fades out from this)
        fresh:     999,           // frames since a bullet was FIRST grazed (the shell's bright white just after)
        grazed:    ds_map_create(), // bullets that have already given their first graze
        flash:     0,              // the bar flashes white when you gain
		broken:    false
    };
}

/// start of a battle
function scr_tp_reset(_dark = false)
{
    scr_tp_init();
    global.tp.value = 0;
    global.tp.dark  = _dark;
    global.tp.grazing = 999;
    global.tp.fresh   = 999;
	global.tp.broken = false;
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

function scr_tp_can_spend(_pct) { scr_tp_init(); return global.tp.broken || global.tp.value >= _pct; }

/// spend _pct TP. false (and nothing spent) if there isn't enough
function scr_tp_spend(_pct)
{
    scr_tp_init();
    if (global.tp.broken) return true;   // the bar's broken: free
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

/// call every step from a bullet (Deltarune's grazing). (_x, _y) its centre, _r its hit radius.
/// _points: the TP % it gives the moment it first comes into graze range (Deltarune's default bullet: 3 of 250 = 1.2%),
/// then _points / 30 every frame it stays in range. _key: unique to this bullet (its id), so the first chunk's only once.
/// no TP (and no graze) while the soul's invulnerable after a hit. returns true if it's grazing this frame
/// (so an attack can shorten itself the way Deltarune's grazing shortens the turn)
function scr_graze(_x, _y, _r, _points = 1.2, _key = id)
{
    scr_tp_init();
    if (!instance_exists(obj_soul)) return false;
    var _s = instance_find(obj_soul, 0);
    if (_s.invulnerable) return false;
    var _d = point_distance(_x, _y, _s.x, _s.y);
    if (_d > _r + global.tp.graze_radius) return false;

    var _mult = global.tp.dark ? global.tp.graze_mult_dark : 1;
    var _k = string(_key);
    if (!ds_map_exists(global.tp.grazed, _k))
    {
        ds_map_add(global.tp.grazed, _k, true);
        if (_points * _mult > 0) scr_tp_add(_points * _mult);
        audio_play_sound(snd_graze, 1, false);
        global.tp.fresh = 0;
    }
    else if (_points * _mult > 0) scr_tp_add(_points * _mult / global.tp.graze_tick_div);
    global.tp.grazing = 0;
    return true;
}

/// slide the TP bar in (true) or out (false). makes it if it isn't there
function scr_tp_bar_show(_on = true)
{
    scr_tp_init();
    if (!instance_exists(obj_tp_bar)) instance_create_depth(0, 0, -100, obj_tp_bar);
    with (obj_tp_bar) shown = _on;
}

/// the TP bar shatters (Susie's "This game is OVER!"): everything's free from now on (scr_tp_reset puts it back)
function scr_tp_break()
{
    scr_tp_init();
    if (global.tp.broken) return;
    global.tp.broken = true;
    if (!instance_exists(obj_tp_bar)) instance_create_depth(0, 0, -100, obj_tp_bar);
    with (obj_tp_bar) break_bar();
}