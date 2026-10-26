// the player-run battle menu (Deltarune style). made by scr_titanspawn_battle_start once the UI's in.
// each turn: Susie, Ralsei, then Queen pick from their box's buttons (left/right, Z picks, X goes back a step),
// then everyone's actions play out (spells / ACTs / items / spares first, then all the FIGHTs together with the
// timing bars), then the enemies' turn (talk + attack from `rounds`), then the next turn.
// the battle's won once every Titan Spawn is defeated or spared.
// what each person has (spells, ACTs, items, numbers) is in scr_battle_menu.

// --- tuning: the text panel under the party boxes (GUI px) ---
panel_y    = 404;
panel_h    = 480 - 404;
text_x     = 24;
line_h     = 24;
text_scale = 1.75;            // the battle text
name_scale = 1.75;            // spell / item / enemy / ally names (Deltarune: the same font size as the descriptions)
desc_scale = 1.75;            // a spell / item's description and TP cost, on the right
desc_line  = 18;              // px between description lines
col_x      = [80, 320];       // the two columns in lists (Deltarune's 60 / 240 on its 640-wide screen)
desc_x     = 613;             // a spell/item's description, TP cost under it (Deltarune's 460)
type_speed = 2;               // letters per frame
flavor     = [
    "* The Titan Spawn writhe in the dark.",
    "* It smells like ozone and old stone.",
    "* The Titan Spawn hunger for light.",
    "* The wind howls around the tower.",
];
col_orange = make_color_rgb(255, 160, 64);
col_grey   = make_color_rgb(128, 128, 128);
col_tired  = make_color_rgb(0, 162, 232);
col_yellow = make_color_rgb(255, 255, 0);

// --- tuning: FIGHT's attack boxes (Deltarune's, GUI px). one row per fighter: their face, a box in their colour,
//     the white reticle near its left end, and their cursor sliding left toward it. Z hits the leftmost cursor
//     that's close enough: it stops dead, flashes, and they attack right then. let it slide past: MISS ---
fb_icon_x     = 26;    // their face
fb_box_x1     = 66;    // the box
fb_box_x2     = 820;
fb_row_h      = 22;
fb_reticle_x  = 92;    // the reticle (a perfect hit lines the cursor up with it)
fb_cursor_w   = 6;
fb_speed      = 4;     // px per frame (Deltarune's 8 px per 30fps frame on a 640 screen is ~5.3 here; a touch slower)
fb_start      = 240;   // px right of the reticle the first cursor starts (it reaches the reticle 60 frames later)
fb_stagger    = [0, 24, 36];   // frames each later cursor comes in after the one before (Deltarune: 0, 12 or 18 of its frames)
fb_hit_range  = 112;   // px before the reticle a cursor can be hit (Deltarune: 14 of its frames early)
fb_crit       = 4;     // px either side of the reticle that's a critical
fb_miss_after = 20;    // px past the reticle before it's a MISS
fb_trail      = 4;     // afterimages behind a moving cursor

// --- tuning: FIGHT damage (Deltarune): round(at * points / 20) - df * 3. points: 150 for a perfect hit, less the further off
crit_points  = 150;

// --- tuning: TP from FIGHT (Deltarune: accuracy / 10, or / 26 in darkness, out of 250) ---
fight_tp_div      = 10;
fight_tp_div_dark = 26;

// --- tuning: the enemies' turn ---
rounds              = [];  // { talk: [ { speaker, text }, ... ], attack: function that starts a box attack and returns it }, cycles
enemy_wait_frames   = 40;  // a round with no attack: just a pause
box_x_nudge         = 0;
box_depth           = -5000;
on_win              = undefined;   // function to run once the battle's won (otherwise Z just works again)

// --- the party: boxes and who can do what, Susie / Ralsei / Queen ---
names   = ["Susie", "Ralsei", "Queen"];
members = array_create(3, noone);
defs    = array_create(3, undefined);
for (var i = 0; i < 3; i++)
{
    var _n = names[i];
    with (obj_battle_ui_box) if (char_name == _n) other.members[i] = id;
    defs[i] = scr_bm_member_def(_n);
}
items = scr_bm_items_default();

// the button cells in each box's art (source px): x of each of the 5, and the row's y/size
cells = {
    Susie:  { xs: [64, 204, 344, 484, 624], y: 160, w: 124, h: 104 },
    Ralsei: { xs: [61, 201, 341, 481, 621], y: 157, w: 124, h: 104 },
    Queen:  { xs: [26, 61, 96, 131, 166],   y: 48,  w: 31,  h: 26  },
};

depth = -10050;   // its Draw GUI goes over the party boxes

// --- state ---
state    = "turn_start";
t        = 0;
turn     = 0;
actions  = array_create(3, undefined);
chooser  = 0;
cmd_i    = array_create(3, 0);
mode     = "cmd";          // cmd / list / enemy / ally (what the chooser's looking at)
list     = [];             // the spells / ACTs / items being shown
list_i   = 0;
pick_i   = 0;              // cursor in the enemy / ally lists
pending  = undefined;      // what's being aimed (a spell, ACT, item, "fight" or "spare")
text     = "";
text_shown = 0;
queue    = [];             // actions left to play out
cur      = undefined;      // the one playing out now
fighters = [];
box_inst = noone;
atk_inst = noone;
talk_chain = noone;

// ---------------------------------------------------------------- helpers
set_text = function(_s) { text = _s; text_shown = 0; }
text_done = function() { return text_shown >= string_length(text); }

alive_member = function(_i) { return members[_i] != noone && instance_exists(members[_i]) && members[_i].hp > 0; }

/// Titan Spawn still in the fight, top to bottom
enemies = function()
{
    var _a = [];
    with (obj_battle_titanspawn) if (!gone) array_push(_a, id);
    array_sort(_a, function(_p, _q) { return sign(_p.home_y - _q.home_y); });
    return _a;
}

/// first party member from _from on who can still act (-1: nobody)
next_chooser = function(_from)
{
    for (var i = _from; i < 3; i++) if (alive_member(i)) return i;
    return -1;
}
/// the last one before _from who's picked something (-1: nobody)
prev_chooser = function(_from)
{
    for (var i = _from - 1; i >= 0; i--) if (actions[i] != undefined) return i;
    return -1;
}

key_ok     = function() { return keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter); }
key_back   = function() { return keyboard_check_pressed(ord("X")) || keyboard_check_pressed(vk_shift); }
snd_move   = function() { audio_play_sound(snd_menumove, 1, false); }
snd_ok     = function() { audio_play_sound(snd_select, 1, false); }
snd_no     = function() { audio_play_sound(snd_cantselect, 1, false); }

/// the pose they hold once they've picked (Deltarune shows what they're about to do)
ready_pose = function(_i, _kind)
{
    // the moment a command's picked (Z on its button) they go into its ready, and hold it until their go.
    // no ready for that command: their ACT ready instead (then on their go they do the real thing). no ACT ready either: idle
    var _d = defs[_i];
    var _hold = variable_struct_exists(_d, "ready_hold") && _d.ready_hold;
    var _spr = -1, _mode = _hold ? 0 : 2;
    switch (_kind)
    {
        case "fight":  _spr = _d.ready_fight; break;
        case "spell":  _spr = _d.ready_magic; break;
        case "act":    _spr = _d.ready_act;  _mode = 0; break;   // Queen's point: its first frame, she points when it's her go
        case "item":   _spr = _d.ready_item; break;
        case "spare":  _spr = -1; break;                         // nobody has a SPARE ready: the ACT ready below
        case "defend":
            // DEFEND happens right away in Deltarune (no turn of its own)
            if (is_string(_d.defend)) { scr_bm_idle(_d); scr_queen_shield_build(); return; }   // Queen builds her shield
            _spr = _d.defend; _mode = 1;                                                        // plays, holds the last frame
        break;
    }
    if (_spr == -1 && _kind != "defend" && _d.ready_act != -1) { _spr = _d.ready_act; _mode = 0; }
    if (_spr == -1) { scr_bm_idle(_d); return; }
    if (instance_exists(_d.obj) && _d.obj.sprite_index == _spr) return;   // already in it (picked the button, now the target): keep it going
    scr_bm_pose(_d.obj, _spr, _mode);
}

/// _i has picked _act: hold their pose, move on to the next person (or start playing it all out)
commit = function(_act)
{
    _act.who = chooser;
    actions[chooser] = _act;
    ready_pose(chooser, _act.kind);
    snd_ok();
    var _n = next_chooser(chooser + 1);
    if (_n == -1) start_execute();
    else begin_choosing(_n);
}

/// undo what _i picked (TP back, item back) so they can choose again
undo = function(_i)
{
    var _a = actions[_i];
    if (_a == undefined) return;
    if (_a.kind == "spell" && _a.spell.tp > 0) scr_tp_add(_a.spell.tp);
    if (_a.kind == "item") array_insert(items, min(_a.slot, array_length(items)), _a.item);
    if (_a.kind == "defend")
    {
        global.tp.value = max(0, global.tp.value - _a.tp_gain);
        if (is_string(defs[_i].defend)) scr_queen_shield_takedown();   // taken down, not broken
    }
    actions[_i] = undefined;
    if (members[_i] != noone) members[_i].defending = false;
    scr_bm_idle(defs[_i]);
}

begin_choosing = function(_i)
{
    chooser = _i;
    mode = "cmd";
    pending = undefined;
    if (instance_exists(obj_UI)) obj_UI.active_box = members[_i];
}

/// everyone's picked: spells / ACTs / items / spares in party order, then all the FIGHTs together
start_execute = function()
{
    if (instance_exists(obj_UI)) obj_UI.active_box = noone;
    queue = [];
    fighters = [];
    for (var i = 0; i < 3; i++)
    {
        var _a = actions[i];
        if (_a == undefined || _a.kind == "defend") continue;
        if (_a.kind == "fight")
        {
            // each later cursor comes in 0, 12 or 18 Deltarune frames (0, 24 or 36 here) after the one before
            var _n = array_length(fighters);
            var _gap = (_n == 0) ? 0 : fighters[_n - 1].delay + fb_stagger[irandom(2)];
            if (_n == 2 && _gap == fighters[1].delay && fighters[1].delay == fighters[0].delay) _gap += fb_stagger[1 + irandom(1)];   // all three at once: reroll
            array_push(fighters, { who: i, target: _a.target, delay: _gap, x: fb_reticle_x + fb_start + _gap * fb_speed,
                                   phase: "move", points: 0, crit: false, flash: 0, t: 0, trail: [], stars: [] });
        }
        else array_push(queue, _a);
    }
    cur = undefined;
    state = "exec_next";
    t = 0;
}

/// a target that's gone by the time it's their go: the next one still standing (or noone)
retarget = function(_inst)
{
    if (instance_exists(_inst) && !_inst.gone) return _inst;
    var _e = enemies();
    return (array_length(_e) > 0) ? _e[0] : noone;
}

/// one action playing out. phase 0: start it, 1: wait for the animation, 2: hold while the text/number shows.
/// returns true once it's done
run_action = function(_a)
{
    var _d   = defs[_a.who];
    var _who = names[_a.who];
    _a.t++;
    switch (_a.phase)
    {
        case 0:
            _a.t = 0;
            _a.phase = 1;
            _a.hold = 40;
            switch (_a.kind)
            {
                case "spell":
                    var _sp = _a.spell;
                    if (_sp.effect == "rudebuster")
                    {
                        set_text("* " + _who + " used RUDE BUSTER!");
                        _a.target = retarget(_a.target);
                        _a.fx = instance_create_depth(0, 0, -3000, obj_rude_buster);
                        _a.fx.break_on_hit = false;
                        if (_a.target != noone) { _a.fx.target_x = _a.target.x; _a.fx.target_y = _a.target.y; }
                    }
                    else if (_sp.effect == "scythemare")
                    {
                        set_text("* " + _who + " cast SCYTHEMARE!");
                        scr_bm_pose(_d.obj, _d.ready_magic, false);
                    }
                    else if (_sp.effect == "check" || _sp.effect == "lecture")
                    {
                        // Queen's ACTs
                        scr_bm_pose(_d.obj, _d.spell_anim, true);   // her point plays out and holds
                        if (_sp.effect == "check") { _a.target = retarget(_a.target); set_text((_a.target != noone) ? _a.target.check_text : "* ..."); _a.hold = 110; }
                        else { set_text("* Queen lectured the Titan Spawn on why the Titan's face is Surprisingly Rather Appealing."); _a.hold = 70; }
                    }
                    else
                    {
                        set_text("* " + _who + " cast " + string_upper(_sp.name) + "!");
                        if (_d.spell_anim != -1) scr_bm_pose(_d.obj, _d.spell_anim, true);
                    }
                break;
                case "item":
                    set_text("* " + _who + " used the " + string_upper(_a.item.name) + "!");
                    if (_d.item_anim != _d.ready_item) scr_bm_pose(_d.obj, _d.item_anim, true);
                break;
                case "spare":
                    _a.target = retarget(_a.target);
                    set_text("* " + _who + " spared the Titan Spawn!");
                break;
            }
        break;

        case 1:   // waiting on the animation / projectile, then the effect lands
        {
            var _ready = false;
            if (_a.kind == "spell" && _a.spell.effect == "rudebuster")
                _ready = !instance_exists(_a.fx) || _a.fx.landed;
            else if (_a.kind == "spell" && (_a.spell.effect == "check" || _a.spell.effect == "lecture"))
                _ready = _a.t >= 18;
            else if (_a.kind == "item" && _d.obj.sprite_index == _d.item_anim && _d.item_anim != _d.ready_item)
                _ready = _d.obj.image_speed == 0 || _a.t >= 90;
            else if (_a.kind == "spell" && _d.spell_anim != -1 && _d.obj.sprite_index == _d.spell_anim)
                _ready = _d.obj.image_speed == 0 || _a.t >= 90;
            else _ready = _a.t >= 18;
            if (!_ready) break;

            apply(_a);
            _a.phase = 2;
            _a.t = 0;
        }
        break;

        case 2:   // let the number / text sit, then they go back to idle
            if ((_a.t >= _a.hold && text_done()) || (_a.t >= 15 && text_done() && key_ok()))
            {
                if (!(_a.kind == "spell" && _a.spell.effect == "rudebuster")) scr_bm_idle(_d);
                return true;
            }
        break;
    }
    return false;
}

/// what an action actually does
apply = function(_a)
{
    var _who = names[_a.who];
    var _d   = defs[_a.who];
    switch (_a.kind)
    {
        case "spell":
        {
            var _sp = _a.spell;
            switch (_sp.effect)
            {
                case "rudebuster":
                    _a.target = retarget(_a.target);
                    if (_a.target != noone)
                    {
                        var _rb = max(1, _d.at * 11 + _d.mg * 5 - _a.target.df * 3);
                        _a.target.take_hit(round(_rb * _a.target.rudebuster_mult * random_range(0.95, 1.05)), _d.color);
                    }
                break;
                case "heal":
                    scr_bm_heal(_a.target, _sp.amount);
                break;
                case "revivesong":
                    if (_a.target.hp <= 0) scr_bm_heal(_a.target, ceil(_a.target.max_hp * 0.5) - _a.target.hp);
                    else scr_bm_heal(_a.target, _sp.amount);
                break;
                case "pacify":
                    _a.target = retarget(_a.target);
                    if (_a.target != noone && !_a.target.can_spare) { set_text(_a.target.no_mercy_text); audio_play_sound(snd_cantselect, 1, false); }
                    else if (_a.target != noone && _a.target.is_tired()) { _a.target.spare(); set_text("* The " + _a.target.enemy_name + " was pacified!"); }
                    else { set_text("* But the enemy wasn't TIRED..."); audio_play_sound(snd_cantselect, 1, false); }
                break;
                case "scythemare":
                {
                    var _n = 0, _nomercy = "";
                    with (obj_battle_titanspawn)
                    {
                        if (gone) continue;
                        if (!can_spare) { _nomercy = no_mercy_text; continue; }
                        if (is_tired()) { spare(); _n++; }
                    }
                    if (_n == 0) { set_text(_nomercy != "" ? _nomercy : "* But nobody was TIRED..."); audio_play_sound(snd_cantselect, 1, false); }
                }
                break;
                case "lecture":
                    // they can't be spared, so instead it fires the party up: TP that ignores the darkness
                    scr_tp_add(_sp.amount);
                    audio_play_sound(snd_power, 1, false);
                    set_text("* The party got fired up! (+" + string(_sp.amount) + "% TP)");
                break;
            }
        }
        break;

        case "item":
            switch (_a.item.effect)
            {
                case "heal":   scr_bm_heal(_a.target, _a.item.amount); break;
                case "tp":     scr_tp_add(_a.item.amount); audio_play_sound(snd_boost, 1, false); break;
                case "revive":
                    if (_a.target.hp <= 0) scr_bm_heal(_a.target, _a.target.max_hp - _a.target.hp);
                    else scr_bm_heal(_a.target, ceil(_a.target.max_hp / 2));
                break;
            }
        break;

        case "spare":
            _a.target = retarget(_a.target);
            if (_a.target == noone) break;
            if (!_a.target.can_spare) set_text("* " + _who + " spared the " + _a.target.enemy_name + "!\n" + _a.target.no_mercy_text);
            else if (_a.target.mercy >= 100) _a.target.spare();
            else set_text("* " + _who + " spared the " + _a.target.enemy_name + "!\n* But MERCY was not 100%!");   // Chapter 5's line
        break;
    }
}

/// the battle's won: everything slides away, Z works again (or on_win runs)
end_battle = function()
{
    with (obj_UI) ui_hidden = true;
    scr_tp_bar_show(false);
    scr_queen_shield_takedown();
    if (variable_global_exists("music")) audio_sound_gain(global.music, 0, 900);
    for (var i = 0; i < 3; i++) if (defs[i] != undefined) scr_bm_idle(defs[i]);
    state = "end_wait";
    t = 0;
}