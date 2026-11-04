// after Queen's lines (self_18). obj_titan_attack3 makes this as its last step:
//  1. the camera pans back to Ralsei. he slowly gets up, turns to King, stomps (self_19)
//  2. the flashback (self_20 over it): black, Ralsei light green, King blue. his wheel of fire, he takes it in (redder),
//     fireballs at King (spades block them, then faster and faster until they get through), a pause, the inferno
//     (King to 1 HP), a longer pause, back out: King sitting and shaking, Ralsei angry, Lancer shocked (self_21)
//  3. one more fireball: Queen's shield blocks it (in front of King, and it stays). Ralsei's shocked, Queen walks in (self_22)
//  4. Ralsei & Queen walk back to their battle spots and ready up (self_23), then scr_titan_battle2_start()
//  5. after attack 4 the battle ends: Ralsei's back in his normal sprites, after_battle() (the next cutscene goes there)
// it stays around through the battle: it draws Queen's shield in front of King and keeps him shaking

// ---------------------------------------------------------------- tuning
// --- 1. he gets up ---
cam_rage_x     = 0;        // the camera pans back here to show Ralsei, Lancer & King (room px, its left edge)
cam_pan_time   = 90;
getup_speed    = 0.06;     // frames of spr_ralsei_fall_back a frame, played backwards (slowly)
stomp_speed    = 0.2;      // frames of spr_ralsei_right_angry_stomp a frame
stomp_frame    = 5;        // the frame his foot comes down on
stomp_sound    = snd_impact;
stomp_gain     = 0.5;
talk_gap       = 30;       // frames between a textbox closing and the next thing
// --- 2. the flashback ---
fb_song        = sng_inmemoriam;   // fades in over the black, fades out as the wheel of fire comes out
fb_song_in     = 3000;     // ms it takes to fade in
fb_song_out    = 2000;     // ms it takes to fade out (from when the wheel starts)
fb_black_hold  = 180;      // frames of black before Ralsei & King glow in (the song coming in)
fb_end_black   = 180;      // frames of black after they've faded out, before the scene fades back in
fb_black_time  = 30;       // frames the screen takes to go black...
fb_sil_time    = 30;       // ...then the silhouettes fade in over this many
fb_hold        = 40;       // frames of them before the lines start
fb_out_time    = 50;       // frames the black takes to fade back out at the end
col_ralsei     = make_color_rgb(150, 255, 170);   // his silhouette (light green)...
col_ralsei_red = make_color_rgb(230, 190, 120);   // ...once he's taken the fire in (redder)
col_king       = make_color_rgb(85, 133, 189);    // King's blue (from his sprite)
glow_alpha     = 0.25;     // Ralsei's glow round his silhouette...
glow_pulse     = 0.1;      // ...pulsing by this much...
glow_speed     = 0.08;
glow_red_extra = 0.2;      // ...brighter once he's redder
glow_dist      = 3;        // px it spreads
king_idle_speed = 0.2;
// the wheel of fire
wheel_count    = 8;
wheel_radius   = 48;       // px from his middle
wheel_spin     = 3;        // degrees a frame
wheel_grow     = 40;       // frames it takes to come out
wheel_hold     = 60;       // frames it spins before he takes it in
embrace_time   = 50;       // frames it shrinks into him (as he goes redder)
embrace_hold   = 40;       // frames after that before the first fireball
wheel_sound    = snd_firespell;
embrace_sound  = snd_power;
// the fireballs
shot_count     = 18;
shot_speed     = 3.5;      // px a frame, the first one...
shot_speed_mult = 1.12;    // ...each one this much faster...
shot_speed_max = 15;       // ...up to this
shot_gap       = 55;       // frames between the first two...
shot_gap_mult  = 0.85;     // ...each gap this much shorter...
shot_gap_min   = 10;       // ...down to this
shot_scale     = 2;
always_block   = 4;        // he blocks the first this many for sure...
block_min      = 0.1;      // ...then his chance drops to this by the last one
block_reach    = 150;      // px from him he throws a spade at one
kspade_speed   = 22;
kspade_scale   = 1.5;
flick_speed    = 0.5;      // frames of spr_king_battle_toss a frame
king_hurt_time = 20;       // frames he flashes hurt when one gets through
shot_hit_frac  = 0.04;     // each one that gets through takes this much of his HP
hand_dx        = 22;       // fireballs leave from this far in front of Ralsei's middle
hand_dy        = -4;
// the inferno
pause1         = 70;       // frames of nothing after the last fireball
inferno_time   = 150;      // frames it burns
inferno_rate   = 5;        // flames a frame
inferno_w      = 70;       // px either side of his middle
inferno_hit_at = 30;       // frames in that he drops to 1 HP
inferno_shake  = 3;
pause2         = 110;      // frames after it's burnt out (a little longer)
dmg_col        = make_color_rgb(1, 255, 0);   // Ralsei's colour
// after it
king_sit_sprite = spr_king_kneel_sad;   // swap in a sitting sprite if you make one
king_sit_xs     = 2;       // 2 = the sprite's own way, -2 = flipped
king_sit_shake  = 1;       // px he shakes, sitting there
// --- 3. the last fireball + Queen's shield ---
throw_sprite   = spr_plat_ralsei_fireball;   // his fireball throw, for every fireball (faces right as drawn)
throw_frame    = 3;        // the frame the fireball leaves his hand
throw_speed    = 0.25;     // frames of it a frame (sped up to fit when the throws get quick)
last_speed     = 6;
shield_scale   = 1;
shield_gap     = 14;       // px between King's front and the shield
shield_float   = 12;
shield_build   = 18;       // frames it takes to build up
shield_bob_amp = 3;
shield_bob_speed = 0.06;
queen_stop_dx  = 150;      // Queen walks in to this far right of King's feet
queen_walk     = 2;
// --- 4. back to the Titan ---
battle_pan_time = 120;
party_walk      = 3;
draw_speed      = 0.25;    // frames of spr_ralsei_battle_intro_serious a frame
ready_hold      = 30;
ralsei_idle     = spr_ralsei_battle_idle_mad;   // his battle idle from the second battle on (played at its own speed)
//  5. in the battle: after attack 4 (script_a: the stat boost), attack 5, then script_b (999 isn't enough, the standoff,
//     Pink's bomb, the Freedom Gang, Susie's back) and the 6-person battle (scr_titan_battle3_start)
boost_speed     = 0.25;    // frames of spr_ralsei_spell a frame (the stat boost)
boost_frame     = 6;
boost_to        = 999;     // his stats go to this (his box's HP and max HP count up to it)
boost_count     = 60;      // frames the count-up takes
hit_speed       = 0.3;     // frames of spr_ralsei_attack a frame (the first 999)
hit_frame       = 4;       // the frame it lands
heal_delay      = 30;      // frames after a hit the Titan heals it back
heal_col        = make_color_rgb(150, 90, 255);   // its "+999"
titan_aim       = { x: 330, y: 190 };   // its chest, from its top-left (where the numbers come out)
titan_face      = { x: 344, y: 286 };   // the star on its face, from its top-left (its lasers come out of it, and Pink's bomb hits it)
push_speed      = 0.45;    // his attacks when he pushes harder: this fast to start...
push_speed_mult = 1.25;    // ...each one faster...
push_gap        = 40;      // ...with this many frames between...
push_gap_min    = 12;      // ...shrinking to this
push_end_wait   = 40;      // frames after the last one before the next thing
// the standoff: his fire beam against its laser
beam_frame       = 6;      // the frame of spr_ralsei_spell he holds while he fires
beam_hand        = { x: 14, y: -36 };   // his raised hand in that frame, in spr_ralsei_spell's px from its origin
beam_grow        = 25;     // frames each beam takes to reach the middle
beam_laser_delay = 10;     // frames after his starts that the Titan answers
clash_time       = 240;    // frames they push against each other...
clash_k0         = 0.5;    // ...where they meet (0 = his hand, 1 = its face) to start...
clash_k1         = 0.25;   // ...slowly pushed back toward him
clash_wobble     = 0.03;
tired_time       = 70;     // frames his beam takes to sputter out (and its laser with it)
spent_shake      = 1;      // px Ralsei shakes, holding his defend after the standoff...
spent_shake_gap  = 3;      // ...every this many frames
fire_beam_w      = 14;     // px wide (his)
laser_w         = 12;      // px wide (its)
laser_col_glow  = make_colour_rgb(90, 40, 200);
laser_col       = make_colour_rgb(170, 110, 255);
laser_col_hot   = make_colour_rgb(230, 215, 255);
laser_streaks   = 10;      // streaks of light running down it...
laser_flow      = 22;      // ...this many px a frame
laser_streak_len = 46;
fire_col_glow   = make_colour_rgb(200, 40, 0);
fire_col        = make_colour_rgb(255, 120, 20);
fire_col_hot    = make_colour_rgb(255, 220, 90);
fire_flames     = 18;      // flames riding his beam...
fire_flow       = 0.035;   // ...how fast they go down it (of its length a frame)
fire_embers     = 14;
pause_time       = 180;    // the dramatic pauses (frames of silence)
// its laser at him
laser_charge    = 50;      // frames its face glows first
laser_hold      = 30;      // frames it fires for
laser_fade      = 20;
wince_xs        = 2;       // spr_ralsei_fall_wince's facing (2 = as drawn, -2 = flipped)
// Queen steps in
queen_guard_dx  = 80;      // Queen stands this far right of Ralsei's feet
pressure_hits   = 3;       // the Titan hammers her shield this many times...
pressure_gap    = 50;
pressure_dmg    = 100;     // (it has 400: it holds, just)
pressure_push   = 14;
// Pink's bomb (from off the left of the screen)
bomb_from       = { x: -60, y: 300 };   // screen px
bomb_time       = 55;
bomb_arc        = 180;
// the Freedom Gang: where they're standing (room px from the battle's camera x: their feet), and the camera
gang_pan        = 300;     // px the camera pans left to show them
gang_spots      = { pink: { x: -60, y: 205 }, jevil: { x: -110, y: 140 }, spamton: { x: -100, y: 262 } };   // left of the battle's view: already there when the camera pans
gang_song       = sng_needsomefriends;
gang_song_in    = 2000;    // ms it fades in over
// who talks in what colour in the battle panel (the textbox's): Pink's goes white to pink
say_cols = {
    susie:  make_colour_rgb(175, 103, 175), ralsei: make_colour_rgb(77, 204, 142),  queen:   make_colour_rgb(111, 209, 255),
    king:   make_colour_rgb(96, 128, 192),  lancer: make_colour_rgb(85, 133, 189),  jevil:   make_colour_rgb(109, 109, 192),
    spamton: c_white,
};
pink_col        = make_colour_rgb(255, 138, 144);
// Susie, walking back in from the left (she took the chair back up). from the left of the gang's view
susie_from_dx   = -40;
susie_to_dx     = 330;
susie_y         = 290;
susie_walk      = 2;
ralsei_run      = 6;       // px a frame he runs to her
hug_dx          = 18;      // px Susie's moved so her half of the hug sprite stays where she was
hug_gap         = 40;      // Ralsei's feet are this far right of Susie's when they come apart
hug_speed       = 0.15;    // the hug plays once and holds
// everyone fans out for the 6-person battle (screen px from the battle's camera: their feet). front row (the ones who
// take hits) nearer the Titan, back row behind; staggered so nobody's on top of anybody, all on the floor and above the boxes
fan_spots = {
    queen:   { x: 470, y: 140 }, ralsei: { x: 480, y: 192 }, susie:   { x: 480, y: 252 },
    jevil:   { x: 345, y: 100 }, pink:   { x: 350, y: 175 }, spamton: { x: 350, y: 250 },
};
fan_walk        = 3;
tp_time         = 12;      // Jevil teleports: frames to vanish (and to come back)...
tp_gap          = 16;      // ...frames gone
tp_sound        = snd_appear;
ysort_base      = -2000;   // from the gang on, everyone's depth: this minus their feet's y (further down = in front)
ready_wait      = 40;      // frames they hold their readies before the six boxes come up

// ---------------------------------------------------------------- refs + state
scene = instance_find(obj_tower_top_scene, 0);
vw    = camera_get_view_width(view_camera[0]);
vh    = camera_get_view_height(view_camera[0]);
depth = -9000;   // over everything for the flashback (moved to just in front of King once the shield's up)
t     = 0;

king_hp = 3000;
if (variable_global_exists("titan_fight_hp") && variable_struct_exists(global.titan_fight_hp, "king")) king_hp = global.titan_fight_hp.king;

fb         = { a: 0, sa: 0, target: 0, starget: 0, red: 0, flash: 0 };
wheel      = undefined;
barrage    = undefined;
inferno    = undefined;
shield     = undefined;
shots      = [];
kspades    = [];
bits       = [];
anims      = [];
king_mode  = "idle";
king_t     = 0;
king_shake = { on: false, base: 0, amt: 0 };
music      = noone;
arrived    = 0;
last_hit   = false;
throw_queue = [];          // fireballs waiting to leave his hand: { spd, blocked, shielded }
push        = undefined;   // Ralsei pushing harder: { left, t, spd, gap }
pressure    = undefined;   // the Titan hammering Queen's shield: { left, t }
rage_tint   = 0;           // the red glow over him while he pushes
rage_target = 0;
titan_glow  = 0;           // the dark glow on the Titan when it heals
blasts      = [];          // animated explosions: { spr, x, y, f, fspd, s }
beam        = undefined;   // the standoff: { phase, t, k, fk, lk, fw, fa, la }
beam_loop   = noone;
laser       = undefined;   // its laser at him: { phase, t, a }
bomb        = undefined;   // Pink's bomb: { t, sx, sy, tx, ty, rot, done }
menu        = noone;       // the battle menu (while it's running our scripts)
gang_arrived = 0;
jevil_tp     = undefined;   // { t, x, y, moved, back }
ysort        = false;
lancer_watch = false;   // Lancer's turned round (shocked) at Susie: he turns back once she's past him
ralsei_shake = undefined;   // { base, t } while he's shaking in his defend
boost_hp     = undefined;   // { t, hp0, max0 } while his HP counts up

// ---------------------------------------------------------------- helpers
feet = function(_o) { return scr_get_feet(instance_find(_o, 0)); }
mid  = function(_o) { return scene.body_mid(_o); }
approach = function(_v, _to, _step) { return (_v < _to) ? min(_to, _v + _step) : max(_to, _v - _step); }

/// _o into _spr (frame 0, still) facing _xs, body kept where it is
pose = function(_o, _spr, _xs)
{
    scene.pose_flip(_o, _spr, _xs);
    with (_o) image_speed = 0;
}

/// steps _o's frames from _from to _to at _spd a frame. _ev() runs once on frame _ev_frame
play = function(_o, _from, _to, _spd, _ev_frame = -1, _ev = undefined)
{
    var _i = instance_find(_o, 0);
    if (_i == noone) return;
    for (var k = array_length(anims) - 1; k >= 0; k--) if (anims[k].o == _i) array_delete(anims, k, 1);
    _i.image_index = _from;
    _i.image_speed = 0;
    array_push(anims, { o: _i, f: _from, to: _to, spd: (_to >= _from) ? abs(_spd) : -abs(_spd),
                        ev_frame: _ev_frame, ev: _ev, done: (_to == _from) });
}
anim_done = function(_o)
{
    var _i = instance_find(_o, 0);
    for (var k = 0; k < array_length(anims); k++) if (anims[k].o == _i) return anims[k].done;
    return true;
}

/// _o drawn as a flat _col silhouette
sil = function(_o, _col, _a, _dx = 0, _dy = 0)
{
    var _i = instance_find(_o, 0);
    if (_i == noone || _a <= 0) return;
    gpu_set_fog(true, _col, 0, 0);
    with (_i) draw_sprite_ext(sprite_index, image_index, x + _dx, y + _dy, image_xscale, image_yscale, image_angle, c_white, _a);
    gpu_set_fog(false, c_black, 0, 0);
}

/// fire with a soft glow behind it
fire_draw = function(_spr, _img, _x, _y, _s, _rot, _a)
{
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(_spr, _img, _x, _y, _s * 1.8, _s * 1.8, _rot, c_orange, _a * 0.35);
    gpu_set_blendmode(bm_normal);
    draw_sprite_ext(_spr, _img, _x, _y, _s, _s, _rot, c_white, _a);
}

/// bits: fire puffs, spade chunks, the inferno's flames
add_bit = function(_spr, _x, _y, _vx, _vy, _s, _ds, _life, _glow, _col = -1, _rot = 0, _vr = 0, _g = 0)
{
    array_push(bits, { spr: _spr, x: _x, y: _y, vx: _vx, vy: _vy, s: _s, ds: _ds, t: 0, life: _life, glow: _glow,
                       col: _col, rot: _rot, vr: _vr, g: _g });
}
puff = function(_x, _y, _n)
{
    repeat (_n) add_bit(spr_plat_smallfire, _x, _y, random_range(-2, 2), random_range(-3, -0.5), random_range(0.8, 1.5), 0.01, irandom_range(20, 35), true);
}
spade_bits = function(_x, _y)
{
    var _c = (fb.sa > 0) ? col_king : -1;
    repeat (5) add_bit(spr_spadechunk, _x, _y, random_range(-3, 3), random_range(-4, -1), 0.35, 0, 30, false, _c, random(360), random_range(-15, 15), 0.3);
}

/// where Ralsei's fireballs come out
hand_pos = function()
{
    var _m = mid(obj_ralsei);
    var _f = sign(obj_ralsei.image_xscale);
    return { x: _m.x + hand_dx * _f, y: _m.y + hand_dy };
}
fire_shot = function(_spd, _blocked, _shielded)
{
    var _h = hand_pos(), _k = mid(obj_king);
    array_push(shots, { x: _h.x, y: _h.y, dir: point_direction(_h.x, _h.y, _k.x, _k.y), spd: _spd, f: 0,
                        blocked: _blocked, flicked: false, shielded: _shielded });
    audio_play_sound(snd_firespell, 1, false, 0.7);
}
/// Ralsei throws a fireball: his throw plays, and it leaves his hand on throw_frame. _gap: frames until his next
/// throw (the animation speeds up to fit inside it)
throw_fire = function(_spd, _blocked, _shielded, _gap = 999)
{
    array_push(throw_queue, { spd: _spd, blocked: _blocked, shielded: _shielded });
    if (barrage != undefined) barrage.pending++;
    pose(obj_ralsei, throw_sprite, 2);
    var _last = sprite_get_number(throw_sprite) - 1;
    var _as   = max(throw_speed, (_last + 1) / max(1, _gap - 1));
    play(obj_ralsei, 0, _last, _as, throw_frame, function()
    {
        if (array_length(throw_queue) == 0) return;
        var _q = throw_queue[0];
        array_delete(throw_queue, 0, 1);
        fire_shot(_q.spd, _q.blocked, _q.shielded);
        if (_q.shielded) shield_put();
        if (barrage != undefined) barrage.pending--;
    });
}

// --- King ---
king_idle = function()
{
    king_mode = "idle";
    with (obj_king) { sprite_index = spr_king_battle_idle; image_speed = other.king_idle_speed; hurt_timer = 0; }
}
king_flick = function()
{
    king_mode = "flick";
    with (obj_king) { sprite_index = spr_king_battle_toss; hurt_timer = 0; }   // (lined up with his idle by its origin)
    play(obj_king, 0, sprite_get_number(spr_king_battle_toss) - 1, flick_speed);
}
king_hurt = function(_frames)
{
    king_mode = "hurt";
    king_t = _frames;
    for (var k = array_length(anims) - 1; k >= 0; k--) if (anims[k].o == obj_king.id) array_delete(anims, k, 1);
    with (obj_king) { sprite_index = spr_king_hurt; image_index = 0; image_speed = 0; hurt_timer = 0; }
}
/// a number over his head (over the flashback's black too)
king_damage = function(_amt)
{
    _amt = max(0, _amt);
    king_hp = max(1, king_hp - _amt);
    var _k = instance_find(obj_king, 0);
    var _m = mid(obj_king);
    var _p = scr_trigger_damage_popup(_k, _amt, dmg_col, dmg_col, _m.x - _k.x, _k.bbox_top - _k.y - 10, snd_damagetaken);
    if (_p != noone) _p.depth = depth - 10;
}

// --- Queen's shield (in front of King, facing Ralsei) ---
shield_put = function()
{
    var _k = instance_find(obj_king, 0);
    var _w = sprite_get_width(spr_queen_shield) * shield_scale;
    shield = { x: _k.bbox_left - shield_gap - _w, y: feet(obj_king).y - shield_float, t: 0, flash: 0, bob: 0 };
    var _d = _k.depth;
    with (obj_lancer) _d = min(_d, depth);
    with (obj_ralsei) _d = min(_d, depth);
    depth = _d - 1;
    audio_play_sound(snd_power, 1, false, 0.8);
}
shield_face = function() { return shield.x + sprite_get_width(spr_queen_shield) * shield_scale * 0.4; }

// ---------------------------------------------------------------- in the battle (after attack 4): helpers
/// a straight sprite swap (battle sprites are all lined up by their origins)
swap = function(_o, _spr, _spd)
{
    for (var k = array_length(anims) - 1; k >= 0; k--) if (anims[k].o == instance_find(_o, 0)) array_delete(anims, k, 1);
    with (_o) { sprite_index = _spr; image_index = 0; image_speed = _spd; anim_loop = true; if (variable_instance_exists(id, "last_sprite")) last_sprite = _spr; }
}
battle_cam = function() { return variable_global_exists("titan_battle_cam_x") ? global.titan_battle_cam_x : scene.cam_battle_x; }
titan = function() { return instance_find(obj_titan_reveal, 0); }
/// a point on the Titan (_o: from its top-left)
titan_pt = function(_o)
{
    var _t = titan();
    if (_t == noone) return { x: camera_get_view_x(view_camera[0]) + 700, y: 200 };
    return { x: _t.x + _o.x, y: _t.y + _o.y };
}
/// a number (or word) off the Titan's chest
titan_popup = function(_txt, _col)
{
    var _t = titan();
    if (_t == noone) return;
    var _p = scr_trigger_damage_popup(_t, _txt, _col, _col, titan_aim.x + irandom_range(-14, 14), titan_aim.y + irandom_range(-10, 10), noone);
    if (_p != noone) _p.depth = -9100;
}
titan_hit = function(_amt)
{
    var _t = titan();
    if (_t != noone) _t.hurt_red = 1;
    audio_play_sound(snd_damagetaken, 1, false);
    scr_camera_shake(2, 6);
    titan_popup(_amt, dmg_col);
}
titan_heal = function(_amt)
{
    audio_play_sound(snd_heal, 1, false, 1, 0, 0.6);
    titan_glow = 1;
    titan_popup("+" + string(_amt), heal_col);
}
/// a word over someone's head
head_popup = function(_o, _txt, _col, _snd)
{
    var _i = instance_find(_o, 0);
    var _top = (sprite_get_bbox_top(_i.sprite_index) - sprite_get_yoffset(_i.sprite_index)) * _i.image_yscale - 6;
    var _p = scr_trigger_damage_popup(_i, _txt, _col, _col, 0, _top, _snd);
    if (_p != noone) _p.depth = -9100;
}
/// the panel's text, cleared (between lines, while things happen)
clear = function() { if (instance_exists(menu)) menu.set_text(""); }
/// Ralsei's party box
ralsei_box = function()
{
    var _b = noone;
    with (obj_battle_ui_box) if (char_name == "Ralsei") _b = id;
    return _b;
}
/// out of his serious sprites for the rest of it
/// out of his serious sprites for the rest of it (his idle stays the mad one)
ralsei_normal = function()
{
    with (obj_battle_menu) for (var i = 0; i < party_n; i++)
    {
        if (names[i] != "Ralsei" || defs[i] == undefined) continue;
        defs[i].idle        = other.ralsei_idle;
        defs[i].ready_fight = spr_ralsei_attack_ready_serious;   // (his attack stays mad, like his idle)
        defs[i].attack      = spr_ralsei_attack_serious;
        defs[i].defend      = spr_ralsei_defend;
    }
    var _b = ralsei_box();
    if (_b != noone) with (_b)
    {
        body_idle_sprite = other.ralsei_idle;
        defending = false;   // (his DEFEND from before attack 4 is over)
        // a hurt flash still going would put back the pose he was in when he got hit (his serious defend): cancel it
        if (body_hurt_timer > 0 && instance_exists(body_inst)) body_inst.x = body_saved.x;
        body_hurt_timer = 0;
    }
    swap(obj_ralsei, ralsei_idle, 1);
}
/// Ralsei turns all his stats to 999
stat_boost = function()
{
    swap(obj_ralsei, spr_ralsei_spell, 0);
    play(obj_ralsei, 0, sprite_get_number(spr_ralsei_spell) - 1, boost_speed, boost_frame, function()
    {
        audio_play_sound(snd_power, 1, false);
        audio_play_sound(snd_heal, 1, false);
        var _r = instance_find(obj_ralsei, 0);
        var _f = instance_create_depth(0, 0, _r.depth - 1, obj_heal_flash);
        _f.target      = obj_ralsei;
        _f.duration    = 40;
        _f.flash_color = c_yellow;
        head_popup(obj_ralsei, string(boost_to), c_yellow, noone);
        // his box counts up to it, and his attack goes up with it
        var _b = ralsei_box();
        if (_b != noone) boost_hp = { t: 0, hp0: _b.hp, max0: _b.max_hp };
        with (obj_battle_menu) for (var i = 0; i < party_n; i++)
            if (names[i] == "Ralsei" && defs[i] != undefined) defs[i].at = other.boost_to;
    });
}
/// Ralsei hits the Titan for 999... and it heals it straight back
ralsei_hit = function(_spd)
{
    swap(obj_ralsei, spr_ralsei_attack_serious, 0);
    play(obj_ralsei, 0, sprite_get_number(spr_ralsei_attack_serious) - 1, _spd, hit_frame, function()
    {
        audio_play_sound(snd_attack, 1, false);
        titan_hit(999);
        scr_call_after_frames(function() { titan_heal(999); }, heal_delay);
    });
}
/// he keeps hitting it, faster and faster: _n hits
push_start = function(_n, _spd)
{
    rage_target = 1;
    push = { left: _n, t: push_gap, spd: _spd, gap: push_gap };
}
add_blast = function(_spr, _x, _y, _fspd, _s)
{
    array_push(blasts, { spr: _spr, x: _x, y: _y, f: 0, fspd: _fspd, s: _s, ang: irandom(360) });
}

// --- the standoff ---
/// where his fire comes out (his hand, raised in his spell)
beam_from = function()
{
    var _r = instance_find(obj_ralsei, 0);
    if (_r == noone) return { x: 0, y: 0 };
    return { x: _r.x + beam_hand.x * _r.image_xscale, y: _r.y + beam_hand.y * _r.image_yscale };
}
/// where the two beams meet right now
beam_clash = function()
{
    var _a = beam_from(), _b = titan_pt(titan_face);
    return { x: lerp(_a.x, _b.x, beam.k), y: lerp(_a.y, _b.y, beam.k) };
}
beam_start = function()
{
    rage_target = 1;
    swap(obj_ralsei, spr_ralsei_spell, 0);
    obj_ralsei.image_index = beam_frame;
    beam = { phase: "grow", t: 0, k: clash_k0, fk: 0, lk: 0, fw: 1, fa: 1, la: 1 };
    audio_play_sound(snd_firespell, 1, false);
    beam_loop = audio_play_sound(snd_titan_blastloop, 2, true, 0.5);
}
/// a soft band from (_x1, _y1) to (_x2, _y2): _col down the middle fading out to its edges (draw it under bm_add).
/// _wob > 0: it wavers like fire, and starts thinner at (_x1, _y1)
soft_strip = function(_x1, _y1, _x2, _y2, _w, _col, _a, _wob = 0, _ph = 0)
{
    var _len = point_distance(_x1, _y1, _x2, _y2);
    if (_len < 1 || _a <= 0) return;
    var _d  = point_direction(_x1, _y1, _x2, _y2);
    var _nx = lengthdir_x(1, _d + 90), _ny = lengthdir_y(1, _d + 90);
    var _n  = (_wob == 0) ? 1 : max(2, ceil(_len / 12));
    for (var _side = -1; _side <= 1; _side += 2)
    {
        draw_primitive_begin(pr_trianglestrip);
        for (var i = 0; i <= _n; i++)
        {
            var _k  = i / _n;
            var _o  = (_wob == 0) ? 0 : sin(_k * 9 - t * 0.45 + _ph) * _wob * _k;
            var _hw = _w * 0.5 * ((_wob == 0) ? 1 : (0.55 + 0.45 * _k));
            var _cx = lerp(_x1, _x2, _k) + _nx * _o, _cy = lerp(_y1, _y2, _k) + _ny * _o;
            draw_vertex_colour(_cx, _cy, _col, _a);
            draw_vertex_colour(_cx + _nx * _hw * _side, _cy + _ny * _hw * _side, c_black, _a);
        }
        draw_primitive_end();
    }
}
/// the Titan's laser: a violet glow round a white-hot core, light streaking down it, flaring where it starts and lands
draw_laser = function(_x1, _y1, _x2, _y2, _w, _a)
{
    var _len = point_distance(_x1, _y1, _x2, _y2);
    if (_len < 1 || _a <= 0) return;
    var _d  = point_direction(_x1, _y1, _x2, _y2);
    var _nx = lengthdir_x(1, _d + 90), _ny = lengthdir_y(1, _d + 90);
    var _fl = 1 + 0.08 * sin(t * 1.7) + random_range(-0.04, 0.04);
    gpu_set_blendmode(bm_add);
    soft_strip(_x1, _y1, _x2, _y2, _w * 4.0 * _fl, laser_col_glow, 0.6 * _a);
    soft_strip(_x1, _y1, _x2, _y2, _w * 2.0 * _fl, laser_col,      0.9 * _a);
    soft_strip(_x1, _y1, _x2, _y2, _w * 1.0 * _fl, laser_col_hot,  _a);
    soft_strip(_x1, _y1, _x2, _y2, _w * 0.5,       c_white,        _a);
    soft_strip(_x1, _y1, _x2, _y2, _w * 0.5,       c_white,        _a);
    // light streaking down it
    draw_set_alpha(0.7 * _a);
    for (var i = 0; i < laser_streaks; i++)
    {
        var _k  = frac(t * laser_flow / _len + i / laser_streaks);
        var _r  = frac(abs(sin(i * 12.9898)) * 43758.5453);
        var _o  = (_r - 0.5) * _w * 0.9;
        var _sx = lerp(_x1, _x2, _k) + _nx * _o, _sy = lerp(_y1, _y2, _k) + _ny * _o;
        draw_line_width_colour(_sx, _sy, _sx + lengthdir_x(laser_streak_len, _d), _sy + lengthdir_y(laser_streak_len, _d), 2, c_white, laser_col);
    }
    // flares
    draw_set_alpha(_a);
    draw_circle_colour(_x1, _y1, _w * 2.4 * _fl, c_white, c_black, false);
    draw_circle_colour(_x2, _y2, _w * 1.8 * _fl, laser_col_hot, c_black, false);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}
/// Ralsei's fire beam: layers of wavering flame round a white-hot core, flames riding it and embers flying off
draw_fire_beam = function(_x1, _y1, _x2, _y2, _w, _a)
{
    var _len = point_distance(_x1, _y1, _x2, _y2);
    if (_len < 1 || _a <= 0) return;
    var _d  = point_direction(_x1, _y1, _x2, _y2);
    var _nx = lengthdir_x(1, _d + 90), _ny = lengthdir_y(1, _d + 90);
    gpu_set_blendmode(bm_add);
    soft_strip(_x1, _y1, _x2, _y2, _w * 3.4, fire_col_glow, 0.55 * _a, _w * 0.5,  0);
    soft_strip(_x1, _y1, _x2, _y2, _w * 2.0, fire_col,      0.9 * _a,  _w * 0.35, 1.3);
    soft_strip(_x1, _y1, _x2, _y2, _w * 1.0, fire_col_hot,  _a,        _w * 0.25, 2.1);
    soft_strip(_x1, _y1, _x2, _y2, _w * 0.45, c_white,      _a,        _w * 0.15, 2.1);
    // flames riding it, licking back the way they came
    var _fs = _w * 1.3 / sprite_get_width(spr_plat_fire);
    for (var i = 0; i < fire_flames; i++)
    {
        var _r  = frac(abs(sin(i * 78.233)) * 43758.5453);
        var _k  = frac(t * fire_flow + i / fire_flames + _r * 0.05);
        var _o  = (_r - 0.5) * _w * 1.2 * _k + sin(t * 0.3 + i) * _w * 0.2;
        var _fx = lerp(_x1, _x2, _k) + _nx * _o, _fy = lerp(_y1, _y2, _k) + _ny * _o;
        var _s  = _fs * (0.6 + 0.8 * _k) * (0.7 + 0.5 * _r);
        draw_sprite_ext(spr_plat_fire, 0, _fx, _fy, _s, _s, _d + 90 + sin(t * 0.4 + i) * 12,
            merge_colour(c_white, fire_col, _k), _a * sin(_k * pi));
    }
    // embers flying off
    for (var j = 0; j < fire_embers; j++)
    {
        var _r = frac(abs(sin(j * 39.346)) * 43758.5453);
        var _k = frac(t * fire_flow * 1.4 + j / fire_embers);
        var _o = (_r - 0.5) * _w * 3.2 * _k;
        draw_set_alpha(_a * (1 - _k));
        draw_circle_colour(lerp(_x1, _x2, _k) + _nx * _o, lerp(_y1, _y2, _k) + _ny * _o, 2 + _r * 2, fire_col_hot, fire_col, false);
    }
    // his hand, burning
    draw_set_alpha(_a);
    draw_circle_colour(_x1, _y1, _w * 1.4 * (1 + 0.1 * sin(t * 0.8)), fire_col_hot, c_black, false);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

// --- its laser at him ---
laser_start = function()
{
    laser = { phase: "charge", t: 0, a: 1 };
    audio_play_sound(snd_titan_petrify_blast, 1, false);
}
/// it lands: he's down to 1 HP, on his knee
laser_hit = function()
{
    if (ralsei_shake != undefined) { with (obj_ralsei) x = other.ralsei_shake.base; ralsei_shake = undefined; }
    audio_play_sound(snd_explosion, 1, false);
    audio_play_sound(snd_hurt, 1, false);
    scr_camera_shake(10, 30);
    fb.flash = 1;
    rage_target = 0;
    var _m = mid(obj_ralsei);
    add_blast(spr_titan_shockwave_bullet_explosion, _m.x, _m.y, 0.25, 1);
    pose(obj_ralsei, spr_ralsei_fall_wince, wince_xs);
    var _b = ralsei_box();
    if (_b != noone)
    {
        var _dmg = max(0, _b.hp - 1);
        _b.hp = 1;
        _b.hurt_timer = _b.hurt_flash_time;
        scr_party_head_popup(_b, _dmg, c_white, noone);
    }
}

// --- Queen steps in ---
queen_guard = function()
{
    arrived = 0;
    var _rf = feet(obj_ralsei);
    scr_walk_feet_to(obj_queen, spr_queen_walk_left_unhappy, spr_queen_walk_right_unhappy, spr_queen_walk_up, spr_queen_walk_down_unhappy,
        _rf.x + queen_guard_dx, _rf.y, queen_walk * 2, function() { arrived = 1; });
}
queen_shield = function()
{
    pose(obj_queen, spr_queen_walk_right_unhappy, 2);
    with (obj_queen_shield) instance_destroy();
    with (instance_create_depth(0, 0, 0, obj_queen_shield)) { section_every = 1; side = 1; side_k = 1; follow_queen(); }
}

// --- Pink's bomb, then the Freedom Gang ---
bomb_start = function()
{
    var _f = titan_pt(titan_face);
    bomb = { t: 0, sx: camera_get_view_x(view_camera[0]) + bomb_from.x, sy: camera_get_view_y(view_camera[0]) + bomb_from.y,
             tx: _f.x, ty: _f.y, rot: 0, done: false };
    audio_play_sound(snd_bombfall, 1, false);
}
/// Ralsei's up (shocked), and he and Queen turn round to see who threw that
turn_round = function()
{
    pose(obj_ralsei, spr_ralsei_shocked, -2);   // (facing them: his battle sprites face right as drawn)
    pose(obj_queen, spr_queen_walk_left_unhappy, 2);
    with (obj_queen_shield) if (state == "build" || state == "up") { state = "down"; t = 0; }
}
/// _i standing on _spr (facing right) with its feet on (_x, _y)
stand = function(_i, _spr, _x, _y, _spd)
{
    with (_i) { sprite_index = _spr; image_index = 0; image_speed = _spd; image_xscale = 2; image_yscale = 2; visible = true; image_alpha = 1; if (variable_instance_exists(id, "last_sprite")) last_sprite = _spr; }
    scene.set_feet(_i, _x, _y);
    with (_i) { if (variable_instance_exists(id, "start_y")) start_y = y; if (variable_instance_exists(id, "expected_y")) expected_y = y; }
}
/// Pink, Jevil & Spamton, where they came up (off the left of the screen until the camera pans)
place_gang = function()
{
    var _bc = battle_cam();
    var _p = instance_exists(obj_mewmew)  ? instance_find(obj_mewmew, 0)  : instance_create_layer(0, 0, "Instances", obj_mewmew);
    var _j = instance_exists(obj_jevil)   ? instance_find(obj_jevil, 0)   : instance_create_layer(0, 0, "Instances", obj_jevil);
    var _s = instance_exists(obj_spamton) ? instance_find(obj_spamton, 0) : instance_create_layer(0, 0, "Instances", obj_spamton);
    with (_p) { corrupted = true; ghosted = false; }
    stand(_p, spr_mewmew_idle_corrupted, _bc + gang_spots.pink.x,    gang_spots.pink.y,    1);
	with (_j) bob_on = false;   // (dancing in battle: no float bob)
    stand(_j, spr_jevil_dance,           _bc + gang_spots.jevil.x,   gang_spots.jevil.y,   1);
    stand(_s, spr_spamton_right,         _bc + gang_spots.spamton.x, gang_spots.spamton.y, 0);
    // (the tower's shadow on them too, like everyone else)
    if (instance_exists(obj_shadow_tint))
        with (obj_shadow_tint) { if (!array_contains(shade_objs, obj_mewmew)) array_push(shade_objs, obj_mewmew, obj_jevil, obj_spamton); }
    ysort = true;   // (from now on everyone's sorted by where they're standing)
}
gang_music = function()
{
    if (variable_global_exists("music")) audio_stop_sound(global.music);
    music = audio_play_sound(gang_song, 2, true, 0);
    audio_sound_gain(music, 1, gang_song_in);
    global.music = music;
    global.song  = { sound: gang_song, beats: 9999 };
    global.song_start = current_time;
}

// --- Susie ---
susie_enter = function()
{
    var _cx = battle_cam() - gang_pan;   // (the camera stays on the gang: she walks in from the left of the screen)
    with (obj_susie) { visible = true; image_angle = 0; image_alpha = 1; image_xscale = 2; image_yscale = 2; }
    scene.place(obj_susie, spr_susie_walk_right_neutral, _cx + susie_from_dx, susie_y);
    arrived = 0;
    scr_walk_feet_to(obj_susie, spr_susie_walk_left_neutral, spr_susie_walk_right_neutral, spr_susie_walk_up, spr_susie_walk_down_neutral,
        _cx + susie_to_dx, susie_y, susie_walk, function() { arrived = 1; });
    // Lancer turns round at her, shocked
    pose(obj_lancer, spr_lancer_battle_hurt, -2);
    lancer_watch = true;
}
ralsei_run_to_susie = function()
{
    arrived = 0;
    var _sf = feet(obj_susie);
    pose(obj_ralsei, spr_ralsei_run_left, 2);
    scr_walk_feet_to(obj_ralsei, spr_ralsei_run_left, scene.ralsei_right, scene.ralsei_up, scene.ralsei_down,
        _sf.x + hug_gap, _sf.y, ralsei_run, function() { arrived = 1; });
}
hug = function()
{
    with (obj_ralsei) visible = false;
    scene.pose_flip(obj_susie, spr_ralsei_susie_hug, 2);
    with (obj_susie) { x += other.hug_dx; anim_loop = false; }
    play(obj_susie, 0, sprite_get_number(spr_ralsei_susie_hug) - 1, hug_speed);   // once, then it holds
}
/// "Now." she pushes off him
unhug = function()
{
    scene.pose_flip(obj_susie, spr_ralsei_susie_hug_push, 2);
    play(obj_susie, 0, sprite_get_number(spr_ralsei_susie_hug_push) - 1, 0.12);
}
/// two of them again
apart = function()
{
    scene.pose_flip(obj_susie, spr_susie_walk_right_neutral, 2);
    with (obj_susie) { x -= other.hug_dx; image_speed = 0; }
    var _sf = feet(obj_susie);
    with (obj_ralsei) visible = true;
    scene.pose_flip(obj_ralsei, scene.ralsei_left, 2);
    with (obj_ralsei) image_speed = 0;
    scene.set_feet(obj_ralsei, _sf.x + hug_gap, _sf.y);
}

fan_out = function()
{
    with (obj_queen_shield) instance_destroy();
    var _bc = battle_cam();
    scene.pan_cam(_bc, cam_pan_time);
    gang_arrived = 0;
    var _done = function() { gang_arrived++; };
    var _s = fan_spots;
    with (obj_susie)   image_xscale = 2;
    with (obj_ralsei)  image_xscale = 2;
    with (obj_queen)   image_xscale = 2;
    with (obj_mewmew)  image_xscale = 2;
    with (obj_spamton) image_xscale = 2;
    scr_walk_feet_to(obj_susie,   spr_susie_walk_left_neutral, spr_susie_walk_right_neutral, spr_susie_walk_up, spr_susie_walk_down_neutral, _bc + _s.susie.x,   _s.susie.y,   fan_walk, _done);
    scr_walk_feet_to(obj_ralsei,  scene.ralsei_left, scene.ralsei_right, scene.ralsei_up, scene.ralsei_down,                                 _bc + _s.ralsei.x,  _s.ralsei.y,  fan_walk, _done);
    scr_walk_feet_to(obj_queen,   spr_queen_walk_left_unhappy, spr_queen_walk_right_unhappy, spr_queen_walk_up, spr_queen_walk_down_unhappy, _bc + _s.queen.x,   _s.queen.y,   fan_walk, _done);
    scr_walk_feet_to(obj_mewmew,  spr_mewmew_walkright_corrupted, spr_mewmew_walkright_corrupted, spr_mewmew_walkup_corrupted, spr_mewmew_walkright_corrupted, _bc + _s.pink.x, _s.pink.y, fan_walk, _done);
    scr_walk_feet_to(obj_spamton, spr_spamton_left, spr_spamton_right, spr_spamton_right, spr_spamton_right,                                 _bc + _s.spamton.x, _s.spamton.y, fan_walk, _done);
    // Jevil doesn't walk: he teleports (counts as arrived once he's back)
    jevil_tp = { t: 0, x: _bc + _s.jevil.x, y: _s.jevil.y, moved: false, back: false };
    audio_play_sound(tp_sound, 1, false);
}
/// all facing the Titan (Jevil dancing)
face_all_right = function()
{
    pose(obj_susie,  spr_susie_walk_right_neutral, 2);
    pose(obj_ralsei, ralsei_idle, 2);
    with (obj_ralsei) image_speed = 1;   // (his mad idle, at its own speed)
    pose(obj_queen,  spr_queen_walk_right_unhappy, 2);
    swap(obj_mewmew, spr_mewmew_idle_corrupted, 1);
    swap(obj_jevil,  spr_jevil_dance, 1);
    swap(obj_spamton, spr_spamton_right, 0);
}
/// attack readies (Jevil just keeps dancing)
ready_all = function()
{
    swap(obj_susie,   spr_susie_attack_ready, 0);
    swap(obj_ralsei,  spr_ralsei_attack_ready_serious, 0);
    pose(obj_queen,   spr_queen_pie_throw, 2);
    swap(obj_mewmew,  spr_pink_throw_bomb_corrupted, 0);
    swap(obj_spamton, spr_spamton_armsout_right, 0);
    audio_play_sound(snd_taking_out_sword, 1, false);
}

// ---------------------------------------------------------------- the battle's scripts (obj_battle_menu runs them)
// R: run once, U: wait until, W: wait frames, S: a line in the panel ("ralsei" / "queen" / "king" / "lancer" /
// "susie" with their portrait frame; "pink" with her portrait sprite; "jevil" / "spamton" / "susie_off": no face).
// made here so every function in them belongs to this instance
R = function(_f) { return { run: method(id, _f) }; }
U = function(_f) { return { wait_until: method(id, _f) }; }
W = function(_n) { return { wait: _n }; }
S = function(_who, _img, _text, _opt = undefined)
{
    var _f;
    switch (_who)
    {
        case "ralsei":  _f = { spr: spr_ralsei_dialogue, img: _img }; break;
        case "queen":   _f = { spr: spr_queen_dialogue,  img: _img }; break;
        case "king":    _f = { spr: spr_king_dialogue,   img: _img }; break;
        case "lancer":  _f = { spr: spr_lancer_dialogue, img: _img }; break;
        case "susie":   _f = { spr: spr_susie_dialogue,  img: _img }; break;
        case "pink":    _f = { spr: -1, img: 0, voice: snd_empty, col2: pink_col }; break;   // no face, her blips, white to pink
        case "jevil":   _f = { spr: -1, img: 0, voice: snd_jevil };   break;
        case "spamton": _f = { spr: -1, img: 0, voice: snd_spamton }; break;
        default:        _f = { spr: -1, img: 0, voice: snd_susie }; _who = "susie"; break;   // "susie_off": Susie, from off the screen
    }
    _f.col = variable_struct_exists(say_cols, _who) ? say_cols[$ _who] : c_white;
    _f.text = _text;
    if (_opt != undefined)
    {
        var _k = variable_struct_get_names(_opt);
        for (var i = 0; i < array_length(_k); i++) _f[$ _k[i]] = _opt[$ _k[i]];
        if (variable_struct_exists(_f, "on_start")) _f.on_start = method(id, _f.on_start);
    }
    return { say: _f };
}

/// obj_battle_menu asks at the end of each enemy turn: true if we've taken over
on_turn_end = function(_turn)
{
    menu = instance_find(obj_battle_menu, 0);
    if (_turn == 0)
    {
        // after attack 4: the stat boost, then straight into attack 5
        menu.start_script(script_a(), method(id, function() { with (obj_battle_menu) { turn = 1; state = "enemy_turn"; t = 0; } }));
        return true;
    }
    if (_turn == 1)
    {
        // after attack 5: everything, through to the 6-person battle
        menu.start_script(script_b(), method(id, function() { scr_call_after_frames(function() { scr_titan_battle3_start(); }, 1); }));
        return true;
    }
    return false;
}

script_a = function()
{
    return [
        R(function() { ralsei_normal(); }),
        W(20),
        S("queen", 2, "* Why Don't You Like"),
        S("queen", 0, "* Use Your Fire Magic"),
        S("ralsei", 53, "* Magic does less damage against the Titan..."),
        S("queen", 2, "* Then Increase Your Stats"),
        S("ralsei", 36, "* ..."),
        R(function() { clear(); stat_boost(); }),
        U(function() { return anim_done(obj_ralsei); }),
        W(30),
        R(function() { swap(obj_ralsei, ralsei_idle, 1); }),
        S("queen", 27, "* Sick"),
    ];
}

script_b = function()
{
    return [
        // 999... and it heals right back
        R(function() { clear(); ralsei_hit(hit_speed); }),
        U(function() { return anim_done(obj_ralsei); }),
        R(function() { swap(obj_ralsei, ralsei_idle, 1); }),
        W(heal_delay + 50),
        S("ralsei", 52, "* ...Why isn't it working?"),
        S("ralsei", 53, "* It's..."),
        S("ralsei", 32, "* Do I need more???"),
        S("queen", 18, "* No Idea"),

        // over to King + Lancer, and back
        R(function() { clear(); scene.pan_cam(cam_rage_x, cam_pan_time); }),
        U(function() { return !scene.cam_pan.on; }),
        W(20),
        S("king", 3, "* Lancer. Help your father up.", { on_start: function() { king_shake.amt = 3; } }),
        S("lancer", 11, "* ...Don't move, Dad.", { on_start: function()
            { pose(obj_lancer, spr_lancer_battle, 2); scene.slide(obj_lancer, 10, 0, 10, 4); king_shake.amt = king_sit_shake; } }),
        R(function() { clear(); scene.pan_cam(battle_cam(), cam_pan_time); }),
        U(function() { return !scene.cam_pan.on; }),
        W(20),

        // he pushes harder
        R(function() { push_start(2, push_speed); }),
        U(function() { return push == undefined; }),
        S("ralsei", 54, "* If I just... keep going..."),
        S("queen", 2, "* Ralsei Your Body Is Glowing"),
        S("ralsei", 27, "* I'm FINE."),
        R(function() { clear(); push_start(3, push_speed * push_speed_mult * push_speed_mult); }),
        U(function() { return push == undefined; }),

        // his fire beam against its laser, until he's spent... then the dramatic pause
        R(function() { beam_start(); }),
        U(function() { return beam != undefined && beam.phase == "done"; }),
        R(function() { beam = undefined; if (variable_global_exists("music")) audio_sound_gain(global.music, 0, 1500); }),
        W(pause_time),

        // its laser at him: 1 HP, down on his knee
        R(function() { if (variable_global_exists("music")) audio_stop_sound(global.music); laser_start(); }),
        U(function() { return laser == undefined; }),
        W(40),

        // Queen gets in front of him, shield up, and it hammers it
        R(function() { queen_guard(); }),
        U(function() { return arrived == 1; }),
        R(function() { queen_shield(); }),
        U(function() { return instance_exists(obj_queen_shield) && obj_queen_shield.state == "up"; }),
        W(20),
        R(function() { pressure = { left: pressure_hits, t: 0 }; }),
        U(function() { return pressure == undefined; }),
        W(30),
        S("queen", 2, "* My Shield Is Almost Broken"),
        S("ralsei", 28, "* I..."),
        S("ralsei", 53, "* How are we going to..."),
        R(function() { clear(); }),
        W(pause_time),

        // Pink's bomb, right in its face
        R(function() { bomb_start(); }),
        U(function() { return bomb != undefined && bomb.done; }),
        W(20),
        S("ralsei", 32, "* !!!"),
        R(function() { clear(); bomb = undefined; turn_round(); }),
        W(30),

        // Pink, Jevil & Spamton
        R(function() { place_gang(); gang_music(); scene.pan_cam(battle_cam() - gang_pan, cam_pan_time); }),
        U(function() { return !scene.cam_pan.on; }),
        W(20),
        S("pink", spr_mewmewspeaker_talkhappy_corrupted, "* Need some friends?"),
        S("ralsei", 12, "* How did you guys..."),
        S("jevil", 0, "* WE SAW YOUR FRIEND AT THE BOTTOM, BOTTOM!"),
        S("pink", spr_mewmewspeaker_concerned_corrupted, "* Gerson warned us that you guys would be in trouble."),
        S("pink", spr_mewmewspeaker_talkhappy_corrupted, "* He couldn't make it here, so he sent us instead!"),
        S("ralsei", 28, "* Is Susie..."),
        S("susie_off", 0, "* Susie's good, Ralsei."),

        // she walks back in from the left (she rode the chair back up)
        R(function() { clear(); susie_enter(); }),
        U(function() { return arrived == 1; }),
        R(function() { pose(obj_susie, spr_susie_walk_right_neutral, 2); }),
        W(20),
        S("susie", 30, "* I'm okay."),

        // Ralsei runs over and hugs her
        R(function() { clear(); ralsei_run_to_susie(); }),
        U(function() { return arrived == 1; }),
        R(function() { hug(); }),
        W(30),
        S("susie", 55, "* I'm fine, Ralsei."),
        S("ralsei", 57, "* I was so worried, Susie..."),
        S("susie", 31, "* ..."),
        S("susie", 34, "* Now.", { on_start: function() { unhug(); } }),
        U(function() { return anim_done(obj_susie); }),
        R(function() { apart(); }),
        S("susie", 17, "* Time to deal with that-", { auto: 4, on_start: function() { pose(obj_susie, spr_susie_walk_left_neutral, 2); } }),
        S("ralsei", 48, "* After, Susie.", { on_start: function() { pose(obj_susie, spr_susie_walk_right_neutral, 2); } }),
        S("susie", 15, "* ???"),
        S("ralsei", 27, "* We'll deal with him after."),
        S("susie", 31, "* ..."),
        S("susie", 30, "* ...Okay."),

        // everyone together
        R(function() { clear(); fan_out(); }),
        U(function() { return gang_arrived >= 6 && !scene.cam_pan.on; }),
        R(function() { face_all_right(); }),
        W(20),
        S("susie", 7, "* Everyone ready?"),
        S("spamton", 0, "* [Hell yeah!]"),
        S("susie", 31, "* ..."),
        S("susie", 5, "* Let's do this."),
        S("susie", 34, "* ...again."),
        R(function() { clear(); ready_all(); }),
        W(ready_wait),
    ];
}
// ---------------------------------------------------------------- the script: steps run one after another
steps   = [];
step_i  = 0;
step_t  = 0;
step_on = false;
add = function(_run, _until = undefined, _wait = 0)
{
    var _st = {};
    _st[$ "run"]   = _run;
    _st[$ "until"] = _until;
    _st[$ "wait"]  = _wait;
    array_push(steps, _st);
}

// ---- 1. back to Ralsei: he gets up (slowly), turns to King, stomps
add(function() { scene.pan_cam(cam_rage_x, cam_pan_time); }, function() { return !scene.cam_pan.on; }, 30);
add(function()
{
    // his fall, backwards (same origin as the crying one: a straight swap)
    with (obj_ralsei) { sprite_index = spr_ralsei_fall_back; last_sprite = sprite_index; anim_loop = true; }
    play(obj_ralsei, sprite_get_number(spr_ralsei_fall_back) - 1, 0, getup_speed);
}, function() { return anim_done(obj_ralsei); }, 20);
add(function()
{
    pose(obj_ralsei, spr_ralsei_right_angry_stomp, 2);   // (faces right as drawn: at King)
    with (obj_ralsei) anim_loop = true;
    play(obj_ralsei, 0, sprite_get_number(spr_ralsei_right_angry_stomp) - 1, stomp_speed, stomp_frame, function()
    {
        audio_play_sound(stomp_sound, 1, false, stomp_gain);
        scr_camera_shake(2, 6);
    });
}, function() { return anim_done(obj_ralsei); }, talk_gap);
add(function() { create_textbox("self_19"); }, function() { return !instance_exists(obj_textbox); }, 20);

// ---- 2. the flashback
add(function()
{
    // the screen goes black (in silence)
    fb.target = 1;
    if (variable_global_exists("music")) audio_stop_sound(global.music);
}, function() { return fb.a >= 1; }, fb_black_hold);
add(function()
{
    // (under the black) King squares up to Ralsei in his battle idle, then they glow in, with the song
    scene.pose_flip(obj_king, spr_king_battle_idle, 2);   // his battle sprites face left as drawn
    king_idle();
    fb.starget = 1;
    if (fb_song != noone)
    {
        music = audio_play_sound(fb_song, 2, true, 0);   // (silent, then fades in)
        audio_sound_gain(music, 1, fb_song_in);
        global.music = music;
        global.song  = { sound: fb_song, beats: 9999 };
        global.song_start = current_time;
    }
}, function() { return fb.sa >= 1; }, fb_hold);
add(function() { create_textbox("self_20"); }, function() { return !instance_exists(obj_textbox); }, 20);
add(function()
{
    // the wheel of fire (the song fades out as it comes)
    pose(obj_ralsei, spr_ralsei_spellready, 2);
    with (obj_ralsei) { image_speed = 0.15; anim_loop = true; }
    wheel = { k: 0, ek: 0, rot: 0, embrace: false, gone: false };
    audio_play_sound(wheel_sound, 1, false);
    if (music != noone) audio_sound_gain(music, 0, fb_song_out);
}, function() { return wheel.k >= 1; }, wheel_hold);
add(function()
{
    // he takes it in
    wheel.embrace = true;
    audio_play_sound(embrace_sound, 1, false);
}, function() { return wheel.gone; }, embrace_hold);
add(function()
{
    if (music != noone) { audio_stop_sound(music); music = noone; }   // (faded out by now)
    barrage = { t: 0, next: 0, fired: 0, pending: 0, spd: shot_speed, gap: shot_gap, done: false };
}, function() { return barrage.done; }, pause1);
add(function()
{
    // the inferno
    inferno = { t: 0 };
    fb.flash = 1;
    audio_play_sound(snd_explosion, 1, false);
    audio_play_sound(snd_firespell, 1, false);
    scr_camera_shake(8, 40);
    king_hurt(999999);
    king_shake = { on: true, base: obj_king.x, amt: inferno_shake };
}, function() { return inferno.t >= inferno_time && array_length(bits) == 0; }, pause2);
add(function()
{
    fb.starget = 0;
}, function() { return fb.sa <= 0; }, fb_end_black);
add(function()
{
    // (under the black) King sitting, shaking. Ralsei already back to angry. Lancer shocked, facing his dad
    king_shake.on = false;
    obj_king.x = king_shake.base;
    king_mode = "sit";
    scene.pose_flip(obj_king, king_sit_sprite, king_sit_xs);
    with (obj_king) { image_speed = 0; hurt_timer = 0; }
    king_shake = { on: true, base: obj_king.x, amt: king_sit_shake };
    pose(obj_ralsei, spr_ralsei_right_angry_stomp, 2);
    obj_ralsei.image_index = sprite_get_number(spr_ralsei_right_angry_stomp) - 1;
    pose(obj_lancer, spr_lancer_battle_hurt, 2);   // (faces right as drawn)
    fb.target = 0;
}, function() { return fb.a <= 0; }, talk_gap);
add(function() { create_textbox("self_21"); }, function() { return !instance_exists(obj_textbox); });

// ---- 3. one more fireball: Queen's shield
add(function()
{
    if (music != noone) { audio_stop_sound(music); music = noone; }
    throw_fire(last_speed, false, true);   // (Queen's shield goes up the moment it leaves his hand)
}, function() { return last_hit; }, 20);
add(function()
{
    // Queen walks in from the right
    arrived = 0;
    var _kf = feet(obj_king);
    scr_walk_feet_to(obj_queen, spr_queen_walk_left_unhappy, spr_queen_walk_right_unhappy, spr_queen_walk_up, spr_queen_walk_down_unhappy,
        _kf.x + queen_stop_dx, feet(obj_queen).y, queen_walk, function() { arrived = 1; });
}, function() { return arrived == 1; }, talk_gap);
add(function() { create_textbox("self_22"); }, function() { return !instance_exists(obj_textbox); }, 20);

// ---- 4. back over to the Titan
add(function()
{
    var _cam = variable_global_exists("titan_battle_cam_x") ? global.titan_battle_cam_x : scene.cam_battle_x;
    scene.pan_cam(_cam, battle_pan_time);
    arrived = 0;
    var _done = function() { arrived++; };
    scr_walk_feet_to(obj_ralsei, scene.ralsei_left, scene.ralsei_right, scene.ralsei_up, scene.ralsei_down,
        _cam + scene.party_land_x, scene.ralsei_land_y, party_walk, _done);
    scr_walk_feet_to(obj_queen, spr_queen_walk_left_unhappy, spr_queen_walk_right_unhappy, spr_queen_walk_up, spr_queen_walk_down_unhappy,
        _cam + scene.party_land_x, scene.queen_land_y, party_walk, _done);
}, function() { return arrived >= 2 && !scene.cam_pan.on; }, 10);
add(function()
{
    pose(obj_queen, spr_queen_walk_right_unhappy, 2);   // her battle pose, at the Titan
    pose(obj_ralsei, spr_ralsei_battle_intro_serious, 2);
    play(obj_ralsei, 0, sprite_get_number(spr_ralsei_battle_intro_serious) - 1, draw_speed);
    audio_play_sound(snd_taking_out_sword, 1, false);
}, function() { return anim_done(obj_ralsei); });
add(function() { pose(obj_ralsei, spr_ralsei_attack_ready_serious, 2); }, undefined, ready_hold);
add(function() { create_textbox("self_23"); }, function() { return !instance_exists(obj_textbox); }, 20);
add(function() { scr_titan_battle2_start(); });