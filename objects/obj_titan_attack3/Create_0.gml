// the Titan fight's third enemy turn. it's a whole scene more than an attack, and it ends the battle:
//  1. the box comes up as normal. a beat later Susie's eyes go dark, she shakes harder and harder, and Rude Busters the box
//  2. King: "What the..." (on "the" she Rude Busters him: he's knocked back). she runs at him, guards against a burst of
//     his spades (they shove her back a bit), jumps at him, he gets out of the way. she ends up on the left by the tower's
//     edge, him on the right, the camera following
//  3. a new box in the middle: King's chain attack from Chapter 1 (obj_wavechain, the box on the end of his chain swinging
//     up and down, spades flying in from the left). about 3/4 of the way in she Rude Busters that box too
//  4. her own box, with King's SOUL in it: she throws her axes like her Chapter 1 fight (obj_axebullet) and his SOUL dodges
//     (most of the time). every hit's real damage to King (it can't take him below 1 HP)
//  5. "See? You can't win this." King slowly brings his chain out again and grabs her by her SOUL. "Uh oh." / Ralsei
//     (offscreen): "SUSIE!" and a fireshock at King, knocked away by a spade from Lancer. King swings her round on the chain
//     and throws her off the left edge of the tower, the camera following
//  6. the battle's over: Ralsei runs to the edge (the music fades), then textboxes (self_14 to self_18): Ralsei breaks down,
//     Lancer comes over, King walks up behind them, turns round, the camera pans to Queen walking over, Queen's lines
// made by scr_start_titan_attack3 (scr_titan_battle) once the box is up, like any attack. every function literal here is
// written straight in this event (not inside a { }), so they all belong to this instance

// ---------------------------------------------------------------- tuning
// --- 1. Susie snaps ---
snap_wait        = 150;    // frames after the box is up before her eyes go dark (King's spades have started by then)
open_spade_start = 20;     // King's attack starting: a spade every so often, alternating sides (like attack 1's)...
open_spade_every = 40;
open_spade_speed = 4;
open_spade_off   = 30;     // ...appearing this far outside the box...
open_spade_glide = 80;     // ...gliding in from this much further out...
open_spade_glide_time = 20;
open_spade_wait  = 20;     // ...and waiting there this long before it comes in
lancer_away      = { x: 1000, y: 300 };   // Lancer backs off here (shocked) when she breaks the box (room px: off the screen once
                                          // the camera's moved)
lancer_back_speed = 3;     // px per frame, straight there
shake_ramp       = 90;     // frames she shakes, harder and harder...
shake_max        = 3;      // ...up to this many px
// --- 2. at King ---
king_knock_dx    = -60;    // px King's knocked back by her second Rude Buster
king_knock_time  = 18;
susie_run_speed  = 7;      // px per frame
susie_stop_gap   = 110;    // she stops this far right of King's feet
susie_stop_y     = 205;    // ...at this height
burst_count      = 7;      // spades in King's burst at her
burst_gap        = 6;      // frames between them
burst_speed      = 16;
burst_push       = 4;      // px each one shoves her back
fight_cam_x      = 60;     // the camera pans here as she runs at him, for the rest of the fight (room px; the tower's
                           // edge is at x 240). Lancer's off the right of it
cam_pan_time     = 60;
strike_gap       = 70;     // she jumps at him, aiming to land this far right of his feet...
strike_time      = 26;
strike_hop       = 85;     // (px high)
flick_lead       = 5;      // ...but this many frames before she gets there he flicks a spade into her...
flick_speed      = 26;     // ...this fast...
swing_speed      = 0.5;    // ...(his chain-throw pose, quick, as the flick), and it knocks her flying over him
fling_time       = 44;
fling_hop        = 150;
fling_spin       = 14;     // degrees a frame she tumbles
susie_land       = { x: 290, y: 230 };   // her feet once she's landed (room px): by the edge
land_hold        = 30;     // frames she's down before she's back up
// --- 3. the chain (Deltarune's obj_chainking / obj_wavechain, type 1: 30fps numbers doubled) ---
king_toss_speed  = 0.25;   // frames of spr_king_battle_toss a frame (DR's image_speed 0.5)
king_hold_speed  = 1 / 6;  // spr_king_battle_toss_idle (DR 0.334)
king_hand        = { x: 14, y: 56 };     // his hand in spr_king_battle_toss_idle (source px), where the chain comes from
chain_speed      = 5;      // px per frame it shoots out
chain_piece_gap  = 2;      // a link every this many frames (10px apart, like Deltarune's)
chain_lock_shake = 16;     // px the box shakes when the chain locks onto it (down by 1 a frame)
wave_height      = 80;     // px King bobs up and down (Deltarune's)
wave_slow        = 20;     // sin(siner / this): DR's 10 at 30fps
wave_break_at    = 520;    // ~3/4 of the way in: Susie breaks the box
wave_spade_every = 20;     // a spade from the left every this many frames (faster than DR's 18 at 30fps)
wave_spade_speed = 3;      // px per frame (DR's hspeed 4 is 2)
rail_every       = 12;     // the two rails of spades along the top and bottom of the box: one on each this often...
rail_speed       = 3;      // ...this fast (the top one going right, the bottom one left: a solid wall each)...
rail_off         = 70;     // ...this far up and down from the box's middle (they move with it)
wave_spade_dmg   = 50;
// --- 4. Susie's axes at King's SOUL (Deltarune's obj_susieenemy attack 85 + obj_axebullet, mirrored: she's on the left) ---
axe_start        = 30;     // frames after her box is up before the first
axe_every        = 54;     // frames between axes (DR 27)
axe_time         = 540;    // frames her turn lasts. whatever's still flying then fades out...
axe_last_gap     = 60;     // ...and she stops throwing this many frames before the end
axe_speed_min    = 3.8;    // px per frame out at the start (DR 7.6-9.1)...
axe_speed_rand   = 0.75;
axe_vy_max       = 1;      // ...up or down by up to this (DR +-2)
axe_gravity      = 0.0325; // pulls it back toward her (DR 0.13): it comes back like a boomerang
axe_hit_r        = 18;     // axe -> King's SOUL, px
axe_damage       = 250;    // per hit on King (can't take him below 1)
axe_scale        = 2;
throw_anim_speed = 1 / 6;  // spr_susie_enemy_attack, up to frame 5 (DR 0.334)
ksoul_speed      = 2.6;    // King's SOUL, px per frame
ksoul_dodge      = 0.8;    // it sees this much of the axes coming (the rest it doesn't react to)
ksoul_look       = 45;     // frames ahead it looks for an axe that'll hit it
ksoul_clear      = 34;     // px it tries to keep from an axe's path
ksoul_inv        = 40;     // frames it flashes after a hit
// --- 5. the grab, the fireshock, the throw ---
grab_toss_speed  = 0.08;   // spr_king_battle_toss, slowly this time
grab_speed       = 4;      // px per frame the chain reaches out to her
fire_speed       = 5;      // px per frame, Ralsei's fireshock
fire_scale       = 2;
parry_spade_speed= 20;
parry_before     = 120;    // px right of King's feet Lancer's spade meets it (thrown from off the right of the screen)
spin_hand        = { x: 93, y: 8 };      // the middle of the chain's whirl in spr_king_battle_spin (source px)
spin_radius      = 85;     // px she swings out from it...
spin_pull_time   = 40;     // ...reeled in to that over this many frames (eased)
spin_max         = 13;     // degrees a frame at full speed...
spin_ramp        = 70;     // ...built up to over this many frames (eased in)
spin_turns       = 2;      // full turns before he lets go (at the top, so she flies off to the left)
spin_trail       = 6;      // afterimages behind her while she's swung round and flying
throw_max        = 16;     // px per frame at most when he lets go (she keeps the speed and direction she had)
throw_gravity    = 0.3;
// --- 6. after ---
ralsei_run_speed = 6;
ralsei_stop_x    = 300;    // his feet (room px), just short of the edge
ralsei_slow_from = 110;    // px from there he starts slowing down
music_fade_ms    = 2500;
lancer_gap       = 80;     // Lancer stops this far right of Ralsei
king_gap         = 90;     // King stops this far right of Lancer
queen_stop_x     = 900;    // where Queen stops walking over (room px)
queen_cam_x      = 250;    // the camera pans here to show her coming
queen_pan_time   = 90;
talk_gap         = 30;     // frames between one textbox closing and the next thing

susie_col = make_color_rgb(255, 0, 255);

// ---------------------------------------------------------------- refs + small helpers
scene = instance_find(obj_tower_top_scene, 0);
menu  = instance_find(obj_battle_menu, 0);
vw    = camera_get_view_width(view_camera[0]);
depth = -5100;   // the chain, the axes and King's SOUL go over the box (-5000)

cam   = function() { return instance_exists(scene) ? scene.cam_x : camera_get_view_x(view_camera[0]); }
global.titan_battle_cam_x = cam();   // where the camera sits for the battle (the second one goes back here)
feet  = function(_o) { return scr_get_feet(instance_find(_o, 0)); }
mid   = function(_o) { return scene.body_mid(_o); }
king_target = function()
{
    var _k = noone;
    with (obj_battle_target) if (kind == "king") _k = id;
    return _k;
}
/// Rude Buster damage (the menu's: at * 11 + mg * 5, times its FIGHT multiplier)
buster_damage = function()
{
    var _mult = instance_exists(menu) ? menu.fight_mult : 1;
    return round((20 * 11 + 3 * 5) * _mult * random_range(0.95, 1.05));
}
/// _o (an object) into battle sprite _spr facing _dir (-1 left, 1 right), body where it was. _native: the way _spr faces
pose = function(_o, _spr, _native, _dir) { scene.pose_flip(_o, _spr, 2 * _native * _dir); }
/// a straight sprite swap (for sprites lined up by their origins), keeping which way they face
swap = function(_o, _spr, _spd)
{
    with (_o) { sprite_index = _spr; image_index = 0; image_speed = _spd; if (variable_instance_exists(id, "last_sprite")) last_sprite = _spr; }
}
/// TALKbox lines (obj_dialogue_chain), bubbles at their mouths
say = function(_lines)
{
    var _c = instance_create_depth(0, 0, 0, obj_dialogue_chain);
    _c.auto_mouth = true;
    _c.batches = [ _lines ];
    return _c;
}
talk_done = function() { return !instance_exists(obj_dialogue_chain) && !instance_exists(obj_talkbox); }
/// Susie Rude Busters (_tx, _ty) (undefined: the box's middle). _break: it breaks the box when it lands
buster_at = function(_tx, _ty, _break)
{
    var _b = instance_create_depth(0, 0, -5200, obj_rude_buster);
    _b.target_x     = _tx;
    _b.target_y     = _ty;
    _b.break_on_hit = _break;
    _b.susie_done   = true;   // (it'd put her back in her normal idle: she stays dark-eyed, done below)
    return _b;
}
susie_swing_done = function() { return !instance_exists(obj_susie) || obj_susie.sprite_index != spr_susie_rudebuster || obj_susie.image_speed == 0; }
susie_dark = function(_dir)
{
    with (obj_susie) { sprite_index = spr_susie_battle_idle_dark; last_sprite = sprite_index; image_index = 0; image_speed = 1; anim_loop = true; image_xscale = 2 * _dir; }
}
/// a new battle box in the middle of the screen, set up like the menu's. _soul: false = no player SOUL
spawn_box = function(_soul)
{
    with (obj_battlebox) instance_destroy();
    var _b = scr_spawn_battlebox(instance_exists(menu) ? menu.box_x_nudge : 0);
    _b.depth = instance_exists(menu) ? menu.box_depth : -5000;
    var _s  = instance_exists(menu) ? menu.box_scale : 0.75;
    var _ny = instance_exists(menu) ? menu.box_y_nudge : -16;
    with (_b)
    {
        target_scale_x = _s; target_scale_y = _s;
        prev_target_scale_x = _s; prev_target_scale_y = _s;
        image_xscale = _s; image_yscale = _s;
        box_base_y += _ny;
        x = box_base_x + (raw_width  - raw_width  * image_xscale) / 2;
        y = box_base_y + (raw_height - raw_height * image_yscale) / 2;
        if (!_soul) on_open_callback_done = true;
    }
    return _b;
}
box_up = function() { return instance_exists(obj_battlebox) && obj_battlebox.state == "idle"; }

// --- King's frame-by-frame animations (his chain sprites are lined up with his battle idle by their origins) ---
king_anim = undefined;
king_play = function(_spr, _spd, _loop)
{
    with (obj_king) { sprite_index = _spr; image_index = 0; image_speed = 0; }
    king_anim = { spr: _spr, f: 0, spd: _spd, loop: _loop };
}
king_stop = function(_spr)
{
    king_anim = undefined;
    with (obj_king) { sprite_index = _spr; image_index = 0; image_speed = (_spr == spr_king_battle_idle) ? 1 : 0; }
}
/// where the chain leaves his hand (room px)
king_hand_pos = function()
{
    var _k = instance_find(obj_king, 0);
    var _s = spr_king_battle_toss_idle;
    return { x: _k.x + (king_hand.x - sprite_get_xoffset(_s)) * _k.image_xscale,
             y: _k.y + (king_hand.y - sprite_get_yoffset(_s)) * _k.image_yscale };
}
king_spin_pos = function()
{
    var _k = instance_find(obj_king, 0);
    var _s = spr_king_battle_spin;
    return { x: _k.x + (spin_hand.x - sprite_get_xoffset(_s)) * _k.image_xscale,
             y: _k.y + (spin_hand.y - sprite_get_yoffset(_s)) * _k.image_yscale };
}

// ---------------------------------------------------------------- the running pieces (updated every frame in Step)
shake  = { on: false, t: 0, base: 0 };     // Susie shaking in place
runner = undefined;                         // Susie running at King: { tx, ty }
wave   = undefined;                         // King's chain attack
axes   = [];                                // Susie's axes
ksoul  = undefined;                         // King's SOUL in her box
throwing = false;                           // Susie's still throwing axes
axes_fading = false;                        // her turn's over: the axes still out fade away
throw_t  = 0;
grab   = undefined;                         // King's chain reaching out to Susie's SOUL
ssoul  = undefined;                         // Susie's SOUL (once he's got it): { scale }
fire   = undefined;                         // Ralsei's fireshock
spin   = undefined;                         // her swinging round on the chain, then flying
ral    = undefined;                         // Ralsei running to the edge
cam_follow = false;                         // the camera follows Susie as she's thrown
arrived = 0;                                // (walkers done)
bust    = noone;
opening = false;                            // King's attack has started (before she snaps)
open_t  = 0;
next_side = choose(-1, 1);
tumble  = false;                            // Susie tumbling through the air
flung   = false;                            // King's spade has knocked her out of her jump
jump_to = { x: 0, y: 0 };                   // where her jump was going to landv
movers  = [];                               // people walking straight somewhere: { o, tx, ty, spd, done }

// ---------------------------------------------------------------- the script: steps run one after another
steps   = [];
step_i  = 0;
step_t  = 0;
step_on = false;
/// a step: _run() once, then wait until _until() is true (if given), then _wait more frames
add = function(_run, _until = undefined, _wait = 0)
{
    var _st = {};
    _st[$ "run"]   = _run;
    _st[$ "until"] = _until;
    _st[$ "wait"]  = _wait;
    array_push(steps, _st);
}
wait_frames = function(_n) { add(undefined, undefined, _n); }

// ---- 1. King's attack starts... then Susie snaps
add(function() { opening = true; open_t = 0; }, undefined, snap_wait);
add(function()
{
    // her eyes go dark (facing King), and she starts to shake
    susie_dark(-1);
    shake = { on: true, t: 0, base: obj_susie.x };
}, function() { return shake.t >= shake_ramp; });
add(function()
{
    shake.on = false;
    opening = false;
    obj_susie.x = shake.base;
    bust = buster_at(undefined, undefined, true);   // at the box
}, function() { return !instance_exists(obj_battlebox); });
add(function()
{
    with (obj_soul) instance_destroy();
    // Lancer's shocked (facing his dad), and backs off (straight there, still shocked)
    var _kd = sign(feet(obj_king).x - feet(obj_lancer).x);
    pose(obj_lancer, spr_lancer_battle_hurt, 1, (_kd == 0) ? -1 : _kd);
    with (obj_lancer) { image_speed = 0; image_index = 0; }
    walk_to(obj_lancer, lancer_away.x, lancer_away.y, lancer_back_speed);
}, function() { return susie_swing_done(); }, 10);
// ---- 2. "What the..." (on "the", she Rude Busters him)
add(function()
{
    susie_dark(-1);
    say([ { speaker: obj_king, text: "What the...", instant_cutoff: true } ]);
}, function() { return instance_exists(obj_talkbox) && obj_talkbox.char_index >= 5; });
add(function()
{
    var _m = mid(obj_king);
    bust = buster_at(_m.x, _m.y, false);
}, function() { return !instance_exists(bust) || bust.landed; });
add(function()
{
    // knocked back
    var _kt = king_target();
    if (instance_exists(_kt)) _kt.take_hit(buster_damage(), susie_col);
    scene.slide(obj_king, king_knock_dx, 0, king_knock_time, 10);
}, function() { return susie_swing_done() && talk_done(); }, 20);
add(function()
{
    // she runs at him (overworld run: the battle has no running sprite)
    shake.on = false;
    scene.pose_flip(obj_susie, spr_susie_walk_left_neutral, 2);   // (faces left as drawn)
    with (obj_susie) { image_speed = 2; anim_loop = true; }
    var _kf = feet(obj_king);
    runner = { tx: _kf.x + susie_stop_gap, ty: susie_stop_y };
    scene.pan_cam(fight_cam_x, cam_pan_time);
}, function() { return runner == undefined && !scene.cam_pan.on; });
add(function()
{
    // guards against a burst of his spades: each one shoves her back a little
    pose(obj_susie, spr_susie_defend, 1, -1);
    with (obj_susie) { image_speed = 0; image_index = 0; anim_loop = true; }
    var _k = mid(obj_king);
    for (var i = 0; i < burst_count; i++)
    {
        var _s = mid(obj_susie);
        scene.add_spade(_k.x, _k.y, _s.x, _s.y, burst_speed, i * burst_gap, function()
        {
            audio_play_sound(snd_impact, 1, false, 0.6);
            scene.slide(obj_susie, burst_push, 0, 6, 0);
        });
    }
}, function() { return array_length(scene.spades) == 0; }, 20);
add(function()
{
    // she jumps at him...
    pose(obj_susie, spr_susie_clash_jump, 1, -1);
    with (obj_susie) { image_speed = 0; image_index = 0; }
    audio_play_sound(snd_heavyswing, 1, false);
    var _sf = feet(obj_susie), _kf = feet(obj_king);
    jump_to = { x: _kf.x + strike_gap, y: _kf.y };
    scene.slide(obj_susie, jump_to.x - _sf.x, jump_to.y - _sf.y, strike_time, strike_hop);
}, undefined, strike_time - flick_lead);
add(function()
{
    // ...but right before she gets there, he flicks a spade into her (at where she's about to be)
    flung = false;
    king_play(spr_king_battle_toss, swing_speed, false);
    audio_play_sound(snd_criticalswing, 1, false);
    var _k  = mid(obj_king), _m = mid(obj_susie), _f = feet(obj_susie);
    scene.add_spade(_k.x, _k.y, _m.x + (jump_to.x - _f.x), _m.y + (jump_to.y - _f.y), flick_speed, 0, function()
    {
        // it knocks her flying, right over him to the other side of the tower
        flung = true;
        audio_play_sound(snd_impact, 1, false);
        audio_play_sound(snd_hurt, 1, false);
        scr_camera_shake(7, 14);
        pose(obj_susie, spr_susie_hurt, 1, -1);
        with (obj_susie) { image_speed = 0; image_index = 0; }
        var _sf = feet(obj_susie);
        scene.slide(obj_susie, susie_land.x - _sf.x, susie_land.y - _sf.y, fling_time, fling_hop);   // (replaces her jump)
        tumble = true;
    });
}, function() { return flung; }, fling_time + 2);
add(function()
{
    // she hits the ground by the edge. he turns to face her
    tumble = false;
    obj_susie.image_angle = 0;
    audio_play_sound(snd_impact, 1, false);
    scr_camera_shake(4, 10);
    pose(obj_susie, spr_susie_landed, -1, 1);
    with (obj_susie) { image_speed = 0; image_index = 0; }
    king_stop(spr_king_battle_idle);
    scene.pose_flip(obj_king, spr_king_battle_idle, 2);
    with (obj_king) image_speed = 1;
}, undefined, land_hold);
add(function()
{
    // back up, squared up to him (her body kept where it is: spr_susie_landed's origin is its top-left corner, so a
    // straight swap would jump her up)
    pose(obj_susie, spr_susie_battle_idle_dark, 1, 1);
    with (obj_susie) { image_speed = 1; anim_loop = true; }
}, undefined, 30);

// ---- 3. King's chain attack
add(function() { spawn_box(true); }, function() { return box_up() && instance_exists(obj_soul); }, 20);
add(function()
{
    king_play(spr_king_battle_toss, king_toss_speed, false);
    audio_play_sound(snd_dadblast, 1, false);
}, function() { return king_anim != undefined && king_anim.f >= 3; });
add(function()
{
    audio_play_sound(snd_criticalswing, 1, false);
    king_play(spr_king_battle_toss_idle, king_hold_speed, true);
    var _h = king_hand_pos();
    var _c = scr_box_center();
    wave = { phase: "extend", t: 0, hx: _h.x, hy: _h.y, dir: sign(_c.x - _h.x), pieces: [], hist: [], siner: 0,
             king_y: obj_king.y, box_x: _c.x, box_y: _c.y, shake: chain_lock_shake, btimer: 99, fade: 1,
             snd_extend: audio_play_sound(snd_chain_extend, 5, true), snd_wave: noone, off_x: 0, off_y: 0,
             rails: [], rtimer: 99 };
}, function() { return wave != undefined && wave.t >= wave_break_at; });
add(function()
{
    // ~3/4 in: she Rude Busters the box
    bust = buster_at(undefined, undefined, true);
}, function() { return !instance_exists(obj_battlebox); });
add(function()
{
    with (obj_soul) instance_destroy();
    with (obj_spadebullet) instance_destroy();
    wave_end();
}, function() { return susie_swing_done(); }, 10);

// ---- 4. her box, King's SOUL, her axes
add(function()
{
    susie_dark(1);
    spawn_box(false);
}, function() { return box_up(); });
add(function()
{
    var _c = scr_box_center();
    ksoul = { x: _c.x, y: _c.y, inv: 0, a: 0, wander: random(360) };
    // her Chapter 1 throw (faces left as drawn: mirrored, lined up with her idle by its origin)
    with (obj_susie) { sprite_index = spr_susie_enemy_attack; last_sprite = sprite_index; image_index = 5; image_speed = 0; image_xscale = -2; }
    throwing = true;
    throw_t  = 0;
}, function() { return !throwing; });
add(function()
{
    axes_fading = true;
    if (instance_exists(obj_battlebox)) obj_battlebox.state = "closing";
}, function() { return !instance_exists(obj_battlebox) && array_length(axes) == 0; }, 10);
add(function()
{
    ksoul = undefined;
    // "See? You can't win this."
    swap(obj_susie, spr_susie_attack_ready, 0);
    obj_susie.image_xscale = 2;
    audio_play_sound(snd_swing, 1, false);
    say([ { speaker: obj_susie, text: "See? You can't win this.", to: obj_king } ]);
}, function() { return talk_done() && obj_king.hurt_timer <= 0; }, 20);

// ---- 5. he grabs her by her SOUL
add(function()
{
    king_play(spr_king_battle_toss, grab_toss_speed, false);
}, function() { return king_anim != undefined && king_anim.f >= 3; });
add(function()
{
    audio_play_sound(snd_criticalswing, 1, false);
    king_play(spr_king_battle_toss_idle, king_hold_speed, true);
    grab = { len: 0, locked: false, snd: audio_play_sound(snd_chain_extend, 5, true) };
}, function() { return grab != undefined && grab.locked; }, 30);
add(function()
{
    say([
        { speaker: obj_susie, text: "Uh oh." },
    ]);
}, function() { return talk_done(); });
add(function()
{
    // Ralsei, from offscreen (right): his bubble sits at the right edge of the screen, pointing off it (at his mouth's height)
    var _r = instance_find(obj_ralsei, 0);
    var _tipx = cam() + vw - 16;
    say([ { speaker: obj_ralsei, text: "SUSIE!", offx: _tipx - _r.x, flip: false } ]);
}, function() { return talk_done(); });
add(function()
{
    // his fireshock, at King, from offscreen. Lancer knocks it away with a spade right before it hits
    var _r = mid(obj_ralsei);
    var _k = mid(obj_king);
    var _sx = max(_r.x, cam() + vw + 30);
    var _d  = point_direction(_sx, _r.y, _k.x, _k.y);
    fire = { x: _sx, y: _r.y, vx: lengthdir_x(fire_speed, _d), vy: lengthdir_y(fire_speed, _d), f: 0, rot: 0, hit: false, parried: false, a: 1 };
    audio_play_sound(snd_firespell, 1, false);
}, function() { return fire == undefined; }, 20);
add(function()
{
    // he swings her round on the chain...
    king_play(spr_king_battle_spin, 0.15, true);
    var _p = king_spin_pos();
    var _sm = ssoul_pos();
    var _r0 = point_distance(_p.x, _p.y, _sm.x, _sm.y);
    spin = { phase: "swing", t: 0, ang: point_direction(_p.x, _p.y, _sm.x, _sm.y), w: 0, total: 0, r0: _r0, r: _r0,
             vx: 0, vy: 0, last_whoosh: 0, trail: [] };
    grab.snd = noone;
    pose(obj_susie, spr_susie_hurt, 1, 1);
    with (obj_susie) { image_speed = 0; image_index = 0; }
}, function() { return spin != undefined && spin.phase == "gone"; }, 30);

// ---- 6. the battle's over
add(function()
{
    end_battle_ui();
    king_stop(spr_king_battle_idle);
    // Ralsei runs to where she went over
    scene.pose_flip(obj_ralsei, spr_ralsei_run_left, 2);
    with (obj_ralsei) { image_speed = 1; anim_loop = true; }
    ral = { spd: ralsei_run_speed, slowed: false };
}, function() { return ral != undefined && ral.spd <= 0; }, 40);
add(function()
{
    create_textbox("self_14");   // "N-No..."
}, function() { return !instance_exists(obj_textbox); }, 2);
add(function()
{
    // he falls back (and holds there until he next speaks)
    with (obj_ralsei) { sprite_index = spr_ralsei_fall_back; last_sprite = sprite_index; image_index = 0; image_speed = 1; anim_loop = false; }
}, function() { return obj_ralsei.image_speed == 0; }, 50);
add(function()
{
    with (obj_ralsei) { sprite_index = spr_ralsei_fall_back_cry; last_sprite = sprite_index; image_index = 1; image_speed = 0; anim_loop = true; }
    create_textbox("self_15");   // "S-Susie..." / "I... I could've..."
}, function() { return !instance_exists(obj_textbox); }, talk_gap);
add(function()
{
    // Lancer comes over (sad), then stands by him facing left
    scene.pose_flip(obj_lancer, spr_lancer_left_sad, 2);
    var _rf = feet(obj_ralsei);
    arrived = 0;
    scr_walk_feet_to(obj_lancer, spr_lancer_left_sad, spr_lancer_left_sad, spr_lancer_left_sad, spr_lancer_left_sad,
        _rf.x + lancer_gap, feet(obj_lancer).y, 2, function() { arrived = 1; });   // (straight over to him: no going up or down)
}, function() { return arrived == 1; }, 10);
add(function()
{
    pose(obj_lancer, spr_lancer_battle, 1, -1);
    with (obj_lancer) { image_index = 2; image_speed = 0; }
}, undefined, 30);
add(function() { create_textbox("self_16"); }, function() { return !instance_exists(obj_textbox); }, talk_gap);   // Lancer: "..."
add(function()
{
    // King walks up behind them. his cape tears off his back and flies away (his overworld sprites don't have it)
    var _cape = instance_create_depth(obj_king.x + 46, obj_king.y + 37, obj_king.depth - 1, obj_king_cape);   // (his back, facing left)
    _cape.mode = "leave";
    _cape.dark = false;
    _cape.leave_dir = 20;   // up and away, behind him
    _cape.image_speed = 0.25;
    _cape.depth = obj_king.depth - 1;
    scene.pose_flip(obj_king, spr_king_walk_left, 2);
    var _lf = feet(obj_lancer);
    arrived = 0;
    scr_walk_feet_to(obj_king, spr_king_walk_left, spr_king_walk_left, spr_king_walk_left, spr_king_walk_left,
        _lf.x + king_gap, feet(obj_king).y, 2, function() { arrived = 1; });
}, function() { return arrived == 1; }, 20);
add(function() { create_textbox("self_17"); }, function() { return !instance_exists(obj_textbox); }, 10);   // King, turning round on the last line
add(function()
{
    // Queen, walking over from the right, a long way off. the camera pans to show her
    scene.pose_flip(obj_queen, spr_queen_walk_left_unhappy, 2);
    arrived = 0;
    scr_walk_feet_to(obj_queen, spr_queen_walk_left_unhappy, spr_queen_walk_right_unhappy, spr_queen_walk_up, spr_queen_walk_down_unhappy,
        queen_stop_x, feet(obj_queen).y, 2, function() { arrived = 1; });
    scene.pan_cam(queen_cam_x, queen_pan_time);
}, function() { return arrived == 1 && !scene.cam_pan.on; }, 20);
add(function() { create_textbox("self_18"); }, function() { return !instance_exists(obj_textbox); });
add(function()
{
    instance_create_depth(0, 0, -9000, obj_ralsei_rage);   // Ralsei's turn: it takes it from here
    instance_destroy();
});

// ---------------------------------------------------------------- the pieces' own functions

/// _o walks straight (diagonally if need be) to have its feet on (_tx, _ty), _spd px a frame, keeping its pose
walk_to = function(_o, _tx, _ty, _spd)
{
    var _i = instance_find(_o, 0);
    if (_i == noone) return;
    for (var i = array_length(movers) - 1; i >= 0; i--) if (movers[i].o == _i) array_delete(movers, i, 1);
    array_push(movers, { o: _i, tx: _tx, ty: _ty, spd: _spd });
}

/// where Susie's SOUL is (the middle of her body)
ssoul_pos = function()
{
    var _s = instance_find(obj_susie, 0);
    var _spr = _s.sprite_index;
    var _mx = ((sprite_get_bbox_left(_spr) + sprite_get_bbox_right(_spr) + 1) / 2 - sprite_get_xoffset(_spr)) * _s.image_xscale;
    var _my = ((sprite_get_bbox_top(_spr) + sprite_get_bbox_bottom(_spr) + 1) / 2 - sprite_get_yoffset(_spr)) * _s.image_yscale;
    var _r = scr_rotate_point(_mx, _my, _s.image_angle);
    return { x: _s.x + _r.x, y: _s.y + _r.y };
}

/// the chain attack's over (the box is broken): the links fade, he catches it back, back to his idle
wave_end = function()
{
    if (wave == undefined) return;
    wave.phase = "gone";
    if (wave.snd_extend != noone) audio_stop_sound(wave.snd_extend);
    if (wave.snd_wave != noone) audio_stop_sound(wave.snd_wave);
    king_stop(spr_king_battle_recieve);
    scr_call_after_frames(function() { king_stop(spr_king_battle_idle); }, 30);
}

/// Lancer's spade knocks the fireshock away
parry_fire = function()
{
    if (fire == undefined || fire.parried) return;
    fire.parried = true;
    fire.hit = true;
    fire.vx = 4;
    fire.vy = -7;
    audio_play_sound(snd_criticalswing, 1, false);
    audio_play_sound(snd_impact, 1, false);
    scr_camera_shake(3, 8);
}

/// an axe out of her hand, at the box
throw_axe = function()
{
    var _s = instance_find(obj_susie, 0);
    var _c = scr_box_center();
    array_push(axes, { x: _s.x + 40, y: _c.y, vx: axe_speed_min + random(axe_speed_rand), vy: random_range(-axe_vy_max, axe_vy_max),
                       ang: 0, spin_t: 0, hit: false, seen: (random(1) < ksoul_dodge), a: 1 });
    audio_play_sound(snd_attack, 1, false);
    with (obj_susie) image_index = 0;
}

/// the battle UI goes (the battle's over: Susie's gone)
end_battle_ui = function()
{
    // remember everyone's HP (the second battle carries on from it, and the inferno takes King down to 1)
    global.titan_fight_hp = {};
    with (obj_battle_target) global.titan_fight_hp[$ kind] = hp;
    global.post_battle_hp = {};
    with (obj_battle_ui_box) global.post_battle_hp[$ char_name] = { hp: hp, max_hp: max_hp };
    with (obj_dialogue_chain) instance_destroy();
    with (obj_talkbox) instance_destroy();
    with (obj_soul) instance_destroy();
    with (obj_battlebox) instance_destroy();
    with (obj_battle_target) instance_destroy();
    with (obj_battle_menu) instance_destroy();
    with (obj_battle_ui_box) instance_destroy();
    with (obj_UI) instance_destroy();
    with (obj_tp_bar) instance_destroy();
    scr_queen_shield_break();   // (if she DEFENDed this turn, it'd never have broken: the turn never ended)
    global.cutscene_lock = true;
}