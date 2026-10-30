// the player-run battle menu (Deltarune style). made by scr_titanspawn_battle_start once the UI's in.
// each turn: Susie, Ralsei, then Queen pick from their box's buttons (left/right, Z picks, X goes back a step),
// then everyone's actions play out (spells / ACTs / items / spares first, then all the FIGHTs together with the
// timing bars), then the enemies' turn (talk + attack from `rounds`), then the next turn.
// the battle's won once every Titan Spawn is defeated or spared.
// what each person has (spells, ACTs, items, numbers) is in scr_battle_menu.

// --- tuning: the text panel under the party boxes (GUI px) ---
// Deltarune's layout (numbers from Kristal, which copies it). x's are measured from the party-box row's left edge
panel_y_base = 404;           // the panel's top with the boxes down
panel_lift   = 42;            // the boxes + panel rise this much while the menu's up: top at 362, 118 tall, like Deltarune
panel_y      = panel_y_base;
text_x     = 30;              // the battle text
text_scale = 2;               // Deltarune's font at 2x (yours renders the same glyphs)
name_scale = 2;
desc_scale = 2;
text_line  = 28;              // the battle text's lines
line_h     = 30;              // list rows
desc_line  = 32;              // description lines
col_x      = [30, 260];       // list columns (hearts at 5 and 230)
desc_x     = 500;
col_attack_lines = make_color_rgb(0, 0, 128);   // FIGHT's dark blue row lines
type_speed      = 0.5;        // letters per frame (the textbox's speed)
text_pause      = 0;
text_pause_time = 8;          // frames it stops after . ? ! (half that after ,), like the textbox
sfx_now         = {};         // sounds already started this frame
flavor     = [
    "* The voices from below sound like those in your head.",
    "* When did you start being yourself?",
    "* Almost a reflection, but not quite.",
    "* Ralsei mutters to himself to stay focused.",
	"* Queen seems oddly sustained.",
	"* Don't think what you don't deserve to think about.",
];
col_orange = make_color_rgb(255, 160, 64);
col_grey   = make_color_rgb(128, 128, 128);
col_strip  = make_color_rgb(51, 32, 51);    // the dark purple line along the top of Deltarune's panel
col_hp_bg  = make_color_rgb(128, 0, 0);
col_hp     = make_color_rgb(0, 255, 0);
col_mercy_bg   = make_color_rgb(255, 80, 32);
col_mercy_text = make_color_rgb(128, 0, 0);
col_tired  = make_color_rgb(0, 162, 232);
col_yellow = make_color_rgb(255, 255, 0);
read_time = 30;   // frames an action's text stays up once it's typed out (Z skips)

// --- tuning: FIGHT's attack boxes. Deltarune's, to the pixel across (taken from Kristal, the engine that copies it):
//     one row per fighter (Susie's row 1, Ralsei's 2, Queen's 3, attacking or not), their head at x 21, a 123px box
//     at x 80 in their dark colour, the 8px target at its left end, and their bolt (6px white bar) sliding in from
//     off to the right. Z hits the bolt closest to the target (bolts on the exact same spot both go); it bursts and
//     they swing right away. let it get 2 steps past the target: MISS. the rows are squashed to fit our panel ---
fb_head_x     = 21;     // their face's centre
fb_icon_rects = { Queen: [23, 15, 25, 26] };   // face rects (box-art px) when the box's own one crops it (Queen's did)
fb_box_x      = 80;     // the box's left edge...
fb_box_w      = 123;    // ...and width (Deltarune: 15 bolt steps + 3)
fb_row_h      = 36;     // Deltarune's (the panel's tall enough now)
fb_row_gap    = 2;
fb_head_h     = 24;     // their face's height in the row
fb_bolt_w     = 6;
fb_target_x   = 84;     // the bolt's left edge on a perfect hit (the target's black middle)
fb_step       = 8;      // px per "step": how close a hit is gets measured in these (Deltarune's bolt moves 1 step a frame at 30fps)
fb_speed      = 3;      // px per frame. Deltarune's exact speed is 4 (8px a frame at 30fps): raise it back if it feels slow
fb_first      = 29;     // steps right of the target the first bolt starts (Deltarune: 30 - 1)
fb_gaps       = [0, 10, 15];   // steps between each bolt and the next (random). after a 0 it's 10 or 15, so never three in a line
fb_hit_far    = 15;     // a bolt can be hit from this many steps before the target...
fb_hit_late   = 5;      // ...to this many after
fb_miss_at    = -2;     // this many steps past the target and it's a MISS
fb_after_every = 16;    // px between afterimages (Deltarune: one every 2 frames)
fb_fade_speed = 0.04;   // the rows fade to black once every bolt's done
// their colours: the target, the box, and the bolt after a hit (Deltarune's for Susie / Ralsei. Queen's made the same way from hers)
fb_cols = {
    Susie:  { target: make_color_rgb(234, 121, 200), box: make_color_rgb(128, 0, 128), dmg: make_color_rgb(204, 153, 204) },
    Ralsei: { target: make_color_rgb(181, 230, 29),  box: make_color_rgb(0, 128, 0),   dmg: make_color_rgb(128, 255, 128) },
    Queen:  { target: make_color_rgb(111, 209, 255), box: make_color_rgb(55, 104, 127), dmg: make_color_rgb(183, 232, 255) },
};
fb_flash = 0;           // every box flashes white when Z's pressed
fb_fade  = 0;

// --- tuning: FIGHT damage (Deltarune): round(at * points / 20) - df * 3. points: 150 for a perfect hit, less the further off
crit_points  = 150;
fight_mult   = 2.25;    // FIGHT damage multiplier (1 = Deltarune's own numbers)

// --- tuning: TP from FIGHT (Deltarune: accuracy / 10, or / 26 in darkness, out of 250) ---
fight_tp_div      = 10;
fight_tp_div_dark = 26;

// --- tuning: the enemies' turn ---
rounds              = [];  // { talk: [ { speaker, text }, ... ], attack: function that starts a box attack and returns it }, cycles
rounds_loop_from    = 0;   // once they've all played, it loops back to this one (so a first round can play only once)

/// this turn's round (or undefined)
cur_round = function()
{
    var _n = array_length(rounds);
    if (_n == 0) return undefined;
    var _from = clamp(rounds_loop_from, 0, _n - 1);
    var _i = (turn < _n) ? turn : _from + (turn - _from) mod (_n - _from);
    return rounds[_i];
}
enemy_wait_frames   = 40;  // a round with no attack: just a pause
box_x_nudge         = 0;
box_scale           = 0.75;   // the battle box's size (0.75 stays pixel-perfect at 2x)
box_y_nudge         = -16;    // px up (negative) or down, so there's room under it
box_depth           = -5000;
        on_win = function() { with (obj_tower_top_scene) after_battle(); };   // weapons away, regroup, self_8

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


// --- facing whoever they're aiming at (for fights with enemies on both sides). off unless the battle turns it on ---
facing_enabled = false;
default_facing = 1;        // -1 left, 1 right: which way they face when the battle starts (after that they keep
                           // facing whoever they last picked, turn to turn, until they pick someone the other way)
choose_facing  = 1;        // (which way the one choosing faced before the cursor turned them: X puts them back)

// --- the panel can show a party member's face next to the text (Deltarune's in-battle lines) ---
text_face   = undefined;   // { spr, img } while someone's talking in the panel
say_indent  = 112;         // px the text moves right to make room for the face
face_x      = 10;          // the face's left edge / top, from the panel (GUI px)
face_y      = 10;
face_scale  = 2;

voice_delay = 1;           // like the textbox: a blip every few frames while letters are typing (snd_delay)
voice_count = 0;

/// whose voice goes with a face sprite (the same sounds scr_text gives each character)
face_voice = function(_spr)
{
    if (_spr == spr_susie_dialogue)  return snd_susie;
    if (_spr == spr_ralsei_dialogue) return snd_ralsei;
    if (_spr == spr_lancer_dialogue) return snd_lancer;
    if (_spr == spr_king_dialogue)   return snd_king;
    if (_spr == spr_queen_dialogue)  return snd_queen;
    return noone;
}

// --- a line (or a few) said in the panel before the first turn: { spr, img, text, on_start (optional function) } ---
intro_lines = [];
intro_wait  = 100;         // frames after the battle starts before the first line (the UI sliding in, then a second)

// --- "we're not attacking him": choosing protect_target for an attack makes Susie say protect_lines, then Rude Buster
//     its row in the target list. that row's broken from then on (it can't be picked) ---
protect_target  = noone;
protect_lines   = [];      // { spr, img, text }
protect         = undefined;
protect_hold    = 40;      // frames after the row breaks before they're back to picking
row_shards      = [];      // the broken row's pieces

// --- a scripted moment in the middle of the battle (start_script): a list of steps, then back to whatever was next.
//     steps: { say: { spr, img, text } }  a line in the panel with their face (Z to go on)
//            { talk: [ entries ] }        TALKbox lines (obj_dialogue_chain entries), waits until they're done
//            { run: function }            runs once
//            { wait: frames } / { wait_until: function }
//            { list: true / false }       the panel shows the target list (instead of text) from here on
script       = undefined;
script_list  = false;
fight_hook   = undefined;   // function(_who) the moment someone presses FIGHT: return true if it started a script
auto_mouth   = false;       // TALKbox bubbles go a set distance in front of the speaker's mouth (obj_dialogue_chain)
row_rebuild  = undefined;   // a smashed row coming back together

// --- Susie's Rude Buster at something in the UI (the TP bar, a row in the target list): start_buster ---
buster          = undefined;
buster_speed    = 14;      // px per frame
buster_fire     = 7;       // the frame of spr_susie_rudebuster it leaves her swing on (obj_rude_buster's)
proj_anim_speed = 10 / 60;

// ---------------------------------------------------------------- helpers
text_wrap  = 580;   // px the battle text wraps at (Deltarune's)
text_lines = [];    // the laid-out text: { x, y, from, len } per line (from = where it starts in text)

/// lays the battle text out like Deltarune: "* " sits in its own column, and every other line (wrapped, or a new
/// line without a star) lines up with the words above it. done once per line of text, so words don't jump while typing
layout_text = function(_s)
{
    draw_set_font(fnt_determination);
    var _hang   = string_copy(_s, 1, 2) == "* ";
    var _indent = _hang ? string_width("* ") * text_scale : 0;
    var _out = [];
    var _y   = 0;
    var _pos = 1;   // where this paragraph starts in _s
    var _paras = string_split(_s, "\n");
    for (var p = 0; p < array_length(_paras); p++)
    {
        var _par = _paras[p];
        var _n   = string_length(_par);
        var _i   = 1;
        if (string_copy(_par, 1, 2) == "* ") { array_push(_out, { x: 0, y: _y, from: _pos, len: 2 }); _i = 3; }
        while (_i <= _n)
        {
            // as many whole words as fit (a single word that's too long still goes on its own line)
            var _j = _i, _fit = _i - 1;
            while (_j <= _n)
            {
                var _sp = _j;
                while (_sp <= _n && string_char_at(_par, _sp) != " ") _sp++;
                if (_fit >= _i && string_width(string_copy(_par, _i, _sp - _i)) * text_scale > text_wrap - _indent) break;
                _fit = _sp - 1;
                _j   = _sp + 1;
            }
            array_push(_out, { x: _indent, y: _y, from: _pos + _i - 1, len: _fit - _i + 1 });
            _i = _fit + 2;
            if (_i <= _n) _y += text_line;
        }
        _y   += text_line;
        _pos += _n + 1;   // + the \n
    }
    return _out;
}

/// the battle text. _face = { spr, img } shows someone's face next to it (their in-battle line), undefined = just the text
set_text = function(_s, _face = undefined)
{
    text_face = _face;
    voice_count = voice_delay;   // the first letter blips straight away
    var _wrap = text_wrap;
    if (_face != undefined) text_wrap -= say_indent;   // less room next to the face
    text = _s; text_shown = 0; text_pause = 0; text_lines = layout_text(_s);
    text_wrap = _wrap;
}

/// plays _snd unless it already started this frame (two bolts on the same spot shouldn't double up)
play_once = function(_snd)
{
    var _k = string(_snd);
    if (variable_struct_exists(sfx_now, _k)) return;
    sfx_now[$ _k] = true;
    audio_play_sound(_snd, 1, false);
}
text_done = function() { return text_shown >= string_length(text); }

alive_member = function(_i) { return members[_i] != noone && instance_exists(members[_i]) && members[_i].hp > 0; }

/// Titan Spawn still in the fight, top to bottom
enemies = function()
{
    var _a = [];
    with (obj_battle_titanspawn) if (!gone) array_push(_a, id);
    with (obj_battle_target) if (!gone) array_push(_a, id);
    array_sort(_a, function(_p, _q) { return sign(_p.home_y - _q.home_y); });
    return _a;
}

/// its row in the target list was smashed (it can't be picked)
row_broken = function(_inst) { return variable_instance_exists(_inst, "line_broken") && _inst.line_broken; }

/// from _i, step _dir (1 down / -1 up) through the target list to the next one that can be picked (_i itself if it can)
pick_step = function(_e, _i, _dir)
{
    var _n = array_length(_e);
    if (_n == 0) return 0;
    _i = ((_i mod _n) + _n) mod _n;
    for (var k = 0; k < _n; k++)
    {
        if (!row_broken(_e[_i])) return _i;
        _i = (_i + _dir + _n) mod _n;
    }
    return _i;
}

/// _i turns to face _dir (-1 left, 1 right): just flipped where they stand
face_member = function(_i, _dir)
{
    var _d = defs[_i];
    if (_d == undefined || !instance_exists(_d.obj) || _dir == 0) return;
    with (_d.obj) image_xscale = abs(image_xscale) * _dir;
}

/// Susie Rude Busters something on the screen (GUI px, { x, y }): she swings, it flies there, _on_hit() runs when it lands,
/// and she goes back to however she was standing once her swing's done. buster_busy() is true until all of that's over
start_buster = function(_target, _on_hit)
{
    buster = { phase: "swing", t: 0, tx: _target.x, ty: _target.y, on_hit: _on_hit, saved: undefined, proj: undefined };
    if (instance_exists(obj_susie))
    {
        var _b = buster;
        with (obj_susie)
        {
            _b.saved = { spr: sprite_index, img: image_index, spd: image_speed, loop: anim_loop };
            sprite_index = spr_susie_rudebuster; last_sprite = sprite_index;
            image_index = 0; image_speed = 1; anim_loop = false;
        }
    }
}
buster_busy = function() { return buster != undefined; }

/// the middle of the TP bar (GUI px)
tp_bar_target = function()
{
    if (!instance_exists(obj_tp_bar)) return { x: 50, y: 140 };
    return { x: obj_tp_bar.bar_x, y: obj_tp_bar.bar_y };
}

/// the middle of _inst's row in the target list (GUI px; the panel's shifted to sit under the boxes)
row_target = function(_inst)
{
    var _ox = instance_exists(obj_UI) ? round(obj_UI.x - 1 + obj_UI.boxes_x_correction - camera_get_view_x(view_camera[0])) : 0;
    var _e  = enemies();
    var _ri = 0;
    for (var i = 0; i < array_length(_e); i++) if (_e[i] == _inst) _ri = i;
    return { x: _ox + 230, y: panel_y + 17 + _ri * line_h + 14, row: _ri, ox: _ox };
}

/// _inst's row in the target list smashes (it can't be picked after this)
smash_row = function(_inst, _rt)
{
    _inst.line_broken = true;
    var _y0 = panel_y + 17 + _rt.row * line_h;
    repeat (18)
    {
        array_push(row_shards, { x: _rt.ox + random_range(75, 610), y: _y0 + random_range(0, 28),
            w: irandom_range(4, 18), h: irandom_range(3, 10), col: choose(c_white, c_white, col_hp, col_hp_bg, col_mercy_bg),
            vx: random_range(-4, 4), vy: random_range(-6, -1), rot: random(360), vr: random_range(-12, 12), a: 1 });
    }
    audio_play_sound(snd_glassbreak, 1, false);
    audio_play_sound(snd_impact, 1, false);
    scr_camera_shake(6, 14);
}

/// is this an attack (FIGHT, or a spell that hurts)? (used for protect_target)
is_attack = function(_pending)
{
    if (_pending == "fight") return true;
    return is_struct(_pending) && variable_struct_exists(_pending, "effect") && _pending.effect == "rudebuster";
}

/// run _steps (see `script` above), then _then() (it puts the battle back where it should be)
start_script = function(_steps, _then)
{
    script = { steps: _steps, i: 0, started: false, t: 0, then: _then, chain: noone };
    script_list = false;
    state = "scripted";
    t = 0;
}

/// a smashed row comes back together (its pieces fly back in), then it can be picked again
rebuild_row = function(_inst)
{
    var _rt = row_target(_inst);
    var _y0 = panel_y + 17 + _rt.row * line_h;
    var _pieces = [];
    repeat (18)
    {
        var _tx = _rt.ox + random_range(75, 610), _ty = _y0 + random_range(0, 28);
        array_push(_pieces, { x0: _tx + random_range(-160, 160), y0: _ty + random_range(-140, -40), tx: _tx, ty: _ty,
                              w: irandom_range(4, 18), h: irandom_range(3, 10), col: choose(c_white, c_white, col_hp, col_hp_bg, col_mercy_bg) });
    }
    row_rebuild = { inst: _inst, t: 0, time: 30, pieces: _pieces };
    audio_play_sound(snd_power, 1, false);
}

/// _i picked protect_target to attack: Susie stops them (her lines, then her Rude Buster smashes its row)
start_protect = function()
{
    protect = { phase: "say", i: 0, t: 0 };
    set_text(protect_lines[0].text, { spr: protect_lines[0].spr, img: protect_lines[0].img });
    state = "protect";
    t = 0;
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

// a real press only: the key going from up to down. (keyboard_check_pressed also fires on Windows' key repeat
// while a key's held, which let a held Z hit every FIGHT bolt.) updated once a frame at the top of Step
ok_prev   = true;    // true to start, so a Z still held from before the battle doesn't count
back_prev = true;
ok_press  = false;
back_press = false;
key_ok     = function() { return ok_press; }
key_back   = function() { return back_press; }
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
    if (defs[_i] != undefined && instance_exists(defs[_i].obj)) choose_facing = sign(defs[_i].obj.image_xscale);
    if (instance_exists(obj_UI)) obj_UI.active_box = members[_i];
}

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
            array_push(fighters, { who: i, target: _a.target, x: 0, phase: "move", points: 0, crit: false, close: 0,
                                   col: c_white, scale: 1, alpha: 1, t: 0, ghosts: [], ghost_d: 0, stars: [] });
        }
        else array_push(queue, _a);
    }
    // Deltarune: the attackers go in a random order, the first one 29 steps out, each next one 0, 10 or 15 steps
    // further (never 0 twice running). so two bolts can land on the same spot, but only by chance
    var _order = array_create(array_length(fighters));
    for (var k = 0; k < array_length(_order); k++) _order[k] = k;
    for (var k = array_length(_order) - 1; k > 0; k--) { var _j = irandom(k), _tmp = _order[k]; _order[k] = _order[_j]; _order[_j] = _tmp; }
    var _off = fb_first, _last = -1;
    for (var k = 0; k < array_length(_order); k++)
    {
        if (k > 0) _off += _last;
        fighters[_order[k]].x = fb_target_x + _off * fb_step;
        _last = (_last != 0) ? fb_gaps[irandom(2)] : fb_gaps[1 + irandom(1)];
    }
    fb_flash = 0;
    fb_fade  = 0;
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
                    else if (_sp.effect == "check" || _sp.effect == "brighten")
                    {
                        // Queen's ACTs: she pulls her arm out (her point plays out and holds), and the text waits for Z
                        scr_bm_pose(_d.obj, _d.spell_anim, true);
                        _a.wait_z = true;
                        if (_sp.effect == "check") { _a.target = retarget(_a.target); set_text((_a.target != noone) ? _a.target.check_text : "* ..."); }
                        else set_text("* Queen turned her screen brightness all the way up!\n* The SOUL's light grew!");
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
                {
                    // the whole line up front, so it doesn't start over when it lands
                    _a.target = retarget(_a.target);
                    var _nm = (_a.target != noone) ? _a.target.enemy_name : "Titan Spawn";
                    var _s  = "* " + _who + " spared the " + _nm + "!";
                    if (_a.target != noone && !_a.target.can_spare) _s += "\n" + _a.target.no_mercy_text;
                    else if (_a.target != noone && _a.target.mercy < 100) _s += "\n* But MERCY was not 100%!";   // Chapter 5's line
                    set_text(_s);
                }
                break;
            }
        break;

        case 1:   // waiting on the animation / projectile, then the effect lands
        {
            var _ready = false;
            if (_a.kind == "spell" && _a.spell.effect == "rudebuster")
                _ready = !instance_exists(_a.fx) || _a.fx.landed;
            else if (_a.kind == "spell" && (_a.spell.effect == "check" || _a.spell.effect == "brighten"))
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
            // ACTs wait for Z once their text's out (Deltarune); everything else moves on by itself
            // counts from when the text finished, so it's on screen long enough to read
            _a.read = text_done() ? (variable_struct_exists(_a, "read") ? _a.read + 1 : 1) : 0;
            if ((!variable_struct_exists(_a, "wait_z") && _a.t >= _a.hold && _a.read >= read_time) || (_a.read >= 5 && key_ok()))
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
                        _a.target.take_hit(round(_rb * _a.target.rudebuster_mult * fight_mult * random_range(0.95, 1.05)), _d.color);
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
                case "brighten":
                    // the SOUL's light grows for the rest of the battle (obj_titanspawn_attack1 reads it)
                    global.soul_glow_radius = 63;   // Deltarune: 48 -> 63 for the turn
                    audio_play_sound(snd_power, 1, false);
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
            if (_a.target != noone && _a.target.can_spare && _a.target.mercy >= 100) _a.target.spare();
        break;
    }
}

/// the battle's won: everyone still standing plays their victory pose once (and holds its last frame)
victory_pose = function()
{
    victory_posed = [];
    for (var i = 0; i < 3; i++)
    {
        var _d = defs[i];
        if (_d == undefined || !variable_struct_exists(_d, "victory")) continue;
        if (instance_exists(members[i]) && members[i].hp <= 0) continue;   // down: they stay down
        scr_bm_pose(_d.obj, _d.victory, 1);
        array_push(victory_posed, _d.obj);
    }
}

/// their victory poses have finished (they freeze on the last frame)
victory_done = function()
{
    if (!variable_instance_exists(id, "victory_posed")) return true;
    for (var i = 0; i < array_length(victory_posed); i++)
        if (instance_exists(victory_posed[i]) && victory_posed[i].image_speed != 0) return false;
    return true;
}

/// the battle's won: everything slides away, Z works again (or on_win runs)
end_battle = function()
{
    // remember everyone's HP before the boxes go (the after-battle heal uses it)
    global.post_battle_hp = {};
    with (obj_battle_ui_box) global.post_battle_hp[$ char_name] = { hp: hp, max_hp: max_hp };

    with (obj_UI) ui_hidden = true;
    scr_tp_bar_show(false);
    scr_queen_shield_takedown();
    if (variable_global_exists("music")) audio_sound_gain(global.music, 0, 900);
    state = "end_wait";
    t = 0;

    // back to idle, except whoever's holding their victory pose (they hold it until whatever's next takes over)
    for (var i = 0; i < 3; i++)
    {
        if (defs[i] == undefined) continue;
        if (variable_instance_exists(id, "victory_posed") && array_contains(victory_posed, defs[i].obj)) continue;
        scr_bm_idle(defs[i]);
    }
}