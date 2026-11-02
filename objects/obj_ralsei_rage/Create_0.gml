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

/// the battle's over (obj_battle_menu.on_win)
after_battle = function()
{
    pose(obj_ralsei, scene.ralsei_right, 2);   // out of his serious sprites
    with (obj_queen) image_speed = 0;
    global.dialogue_self = 23;                 // (so Z doesn't reopen an old line)
    global.cutscene_lock = false;
    // the next cutscene goes here
}

// ---------------------------------------------------------------- the script: steps run one after another
steps   = [];
step_i  = 0;
step_t  = 0;
step_on = false;
add = function(_run, _until = undefined, _wait = 0) { array_push(steps, { run: _run, until: _until, wait: _wait }); }

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