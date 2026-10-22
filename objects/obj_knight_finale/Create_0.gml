// ===================================================================
// The end of the Knight fight. Round 14 just starts this object; it
// runs the whole scene from the `steps` list at the bottom: actions
// (the swoon barrage, Ralsei's barrier, King, the Knight leaving, Susie's
// counter + heal beam, running to the door) and normal textboxes
// (scr_game_text cases "rk_finale_1" to "rk_finale_4"), one after another.
// ===================================================================
depth = -3500; // in front of everyone, behind the textbox

// --- tuning ---
swoon_gain    = 5;
zero_color    = make_color_rgb(255, 0, 255);
ralsei_color  = make_color_rgb(1, 255, 0);

// Susie blocking, faster and faster. dur = how long the swoon covers the screen, gap = beat before the next
rapid_hits = [
    { dur: 50, gap: 26 }, { dur: 38, gap: 18 }, { dur: 28, gap: 12 },
    { dur: 20, gap: 9 },  { dur: 14, gap: 6 },  { dur: 10, gap: 4 }
];

// Ralsei's barrier: a big curved wall of light bowing out in front of both of them
ralsei_cast_frame = 4;
barrier_gap       = 30;  // px from whoever's further forward to the front of the curve
barrier_pad       = 34;  // how far it reaches past the tops of their heads / below their feet
barrier_arc       = 58;  // half the curve's angle (bigger = more curved)
barrier_th        = 12;  // how thick it is
barrier_grow      = 18;  // frames to grow in

// the barrage on the barrier: each swoon cuts into the last one
barrage_count = 20;
barrage_int_a = 26;  barrage_int_b = 5;  // frames between swoons, first -> last
barrage_hold  = 40;  // after the last hit

// King comes over and throws. he isn't in this room, so he walks up from below the screen
king_walk_sprite  = spr_king_walk_left;
king_spawn_pad    = 40;   // how far below the bottom of the screen he starts
king_stop_gap     = 230;  // he stops this far right of whoever's further forward...
king_edge_margin  = 30;   // ...but always this far inside the right edge (even after he's knocked back)
king_ground_nudge = -10;  // his feet vs. theirs (negative = a little further back/up)
king_walk_speed   = 2.5;
king_wind         = 20;   // frames he holds before throwing

// his cape flying onto him first (the dark screen), straight into his battle pose. no laugh
cape_spawn_pad  = 40;   // starts this far past the right edge of the screen
cape_sound      = snd_wing;
king_hand_x     = -22;  // where the spade leaves from, from the middle of his body
king_hand_y     = -8;
spade_speed     = 18;
spade_gap       = 8;    // frames between the two spades
spade_spin      = 25;   // degrees per frame
spade_scale     = 1.5;
shard_count     = 28;

// the castle door (the bottom of it): the Knight goes there, then Susie and Ralsei do
door_x           = 420;
door_y           = 50;
leave_frames     = 100;  // the Knight's ball flying there (fades out over the second half)

// Susie gets up: right a bit, then down a bit (room for the heal beam later)
struggle_frames  = 50;
getup_walk_dist  = 150;
getup_down_dist  = 30;
getup_walk_speed = 2;
getup_anim_speed = 1;

// King throws at Susie, she blocks and Rude Busters him
counter_spade_speed = 13;
defend_at_dist      = 90;  // she snaps into her guard when the spade's this close
buster_delay        = 25;
push_dist           = 30;
push_frames         = 14;  // knocked back in his hurt pose, then his cape tears off...
king_stand_sprite   = spr_king_walk_left; // ...and he's left standing without it...
king_fall_delay     = 60;  // ...this long, then he drops to his knees

// the heal beam: she turns around to face Ralsei first
turn_hold   = 25;
heal_frame  = 14;          // frame of spr_susie_heal the beam leaves on
beam_speed  = 6;
beam_scale  = 2;
hand_off_x  = -14;         // where the beam leaves from, from the middle of Susie's body
hand_off_y  = -10;

// running to the door, then a quick fade into the next room
run_speed       = 3.5;
run_extra_up    = -10;   // how far past the bottom of the door they keep going up
run_fade_speed  = 0.08; // they fade out once they get there (per frame)
ralsei_run_wait = 12;   // he starts a beat after her
next_room       = rm_one;
exit_fade_step  = 0.05; // per frame (0.05 = about a third of a second each way)
exit_fade_hold  = 15;   // frames held on black

// --- state ---
action   = "";
busy     = false;
sub      = "";
t        = 0;   // frames in this sub-step
idx      = 0;
swoon_on = noone;
saved    = {};

barrier  = { on: false, broken: false, cx: 0, cy: 0, r: 1, grow: 0, flash: 0, t: 0, cracks: [] };
shards   = [];
spades   = [];
chunks   = [];
ball     = { on: false, x: 0, y: 0, sx: 0, sy: 0, tx: 0, ty: 0, t: 0, frame: 0, xs: 1, scale: 2, alpha: 1 };
beam     = { on: false, x: 0, y: 0, tx: 0, ty: 0, dir: 0, frame: 0, trail: [] };
buster   = noone;
charge_snd = -1;
runners  = [];
step_i   = 0;
wait_t   = 0;
talking  = false;

// ------------------------------------------------------------ helpers

play = function(_name)
{
    action = _name;
    busy   = true;
    sub    = "start";
    t      = 0;
    idx    = 0;
}

go     = function(_sub) { sub = _sub; t = 0; }
finish = function() { action = ""; busy = false; sub = ""; }

/// swaps a sprite keeping the visible body planted
pose = function(_o, _spr, _loop)
{
    if (instance_exists(_o)) scr_set_battle_sprite(_o, _spr, _spr, _loop);
}

/// middle of an instance's visible pixels
body_mid = function(_o)
{
    with (_o)
    {
        return {
            x: x + ((sprite_get_bbox_left(sprite_index) + sprite_get_bbox_right(sprite_index) + 1) / 2 - sprite_get_xoffset(sprite_index)) * image_xscale,
            y: y + ((sprite_get_bbox_top(sprite_index) + sprite_get_bbox_bottom(sprite_index) + 1) / 2 - sprite_get_yoffset(sprite_index)) * image_yscale
        };
    }
    return { x: 0, y: 0 };
}

/// visible edges of an instance
body_rect = function(_o)
{
    with (_o)
    {
        var _ax = x + (sprite_get_bbox_left(sprite_index) - sprite_get_xoffset(sprite_index)) * image_xscale;
        var _bx = x + (sprite_get_bbox_right(sprite_index) + 1 - sprite_get_xoffset(sprite_index)) * image_xscale;
        var _ay = y + (sprite_get_bbox_top(sprite_index) - sprite_get_yoffset(sprite_index)) * image_yscale;
        var _by = y + (sprite_get_bbox_bottom(sprite_index) + 1 - sprite_get_yoffset(sprite_index)) * image_yscale;
        return { x1: min(_ax, _bx), x2: max(_ax, _bx), y1: min(_ay, _by), y2: max(_ay, _by) };
    }
    return undefined;
}

/// a new swoon cuts off whatever swoon is still up
swoon = function(_spr, _dur)
{
    with (obj_swoon) instance_destroy();
    swoon_on = scr_swoon(_spr, _dur, undefined, swoon_gain);
    return swoon_on;
}

/// the "0" over Susie when she blocks (same spot as the round 2 block)
zero_popup = function(_o)
{
    if (!instance_exists(_o)) return;
    var _b = scr_get_body(_o);
    var _h = (sprite_get_bbox_bottom(_o.sprite_index) - sprite_get_bbox_top(_o.sprite_index)) * _o.image_yscale;
    scr_trigger_damage_popup(_o, 0, zero_color, zero_color, _b.x - _o.x, _b.y - _o.y - _h * 0.6);
}

/// "SWOON" over someone's head
swoon_popup = function(_o)
{
    with (obj_battle_ui_box) if (body == _o) { scr_party_swoon_popup(id); break; }
}

/// puts _o in sprite _spr with the bottom-middle of its body on (_bx, _by)
place_body = function(_o, _spr, _bx, _by)
{
    with (_o)
    {
        sprite_index = _spr;
        x = _bx - ((sprite_get_bbox_left(_spr) + sprite_get_bbox_right(_spr) + 1) / 2 - sprite_get_xoffset(_spr)) * image_xscale;
        y = _by - (sprite_get_bbox_bottom(_spr) + 1 - sprite_get_yoffset(_spr)) * image_yscale;
        last_sprite = _spr;
    }
}

/// the right edge of whoever's further forward, and where their feet are
party_front = function()
{
    var _right = -100000, _feet = 0, _n = 0;
    var _list = [obj_susie, obj_ralsei];
    for (var i = 0; i < 2; i++)
    {
        if (!instance_exists(_list[i])) continue;
        var _r = body_rect(_list[i]);
        _right = max(_right, _r.x2);
        _feet += _r.y2;
        _n++;
    }
    if (_n == 0) return { x: 200, y: 360 };
    return { x: _right, y: _feet / _n };
}

// ------------------------------------------------------------ barrier

barrier_build = function()
{
    var _r = [];
    if (instance_exists(obj_susie))  array_push(_r, body_rect(obj_susie));
    if (instance_exists(obj_ralsei)) array_push(_r, body_rect(obj_ralsei));
    if (array_length(_r) == 0) return;

    var _right = -100000, _top = 100000, _bot = -100000;
    for (var i = 0; i < array_length(_r); i++)
    {
        _right = max(_right, _r[i].x2);
        _top   = min(_top, _r[i].y1);
        _bot   = max(_bot, _r[i].y2);
    }
    // a slice of a circle: its middle bulges out to (_right + barrier_gap), its ends reach past them top and bottom
    var _half_h = (_bot - _top) / 2 + barrier_pad;
    barrier.r  = _half_h / dsin(barrier_arc);
    barrier.cx = _right + barrier_gap - barrier.r;
    barrier.cy = (_top + _bot) / 2;
    barrier.on = true;
    barrier.broken = false;
    barrier.grow = 0;
    barrier.cracks = [];
}

/// a point on the barrier at angle _a (0 = its middle), _off px out from its centre line
barrier_point = function(_a, _off)
{
    return { x: barrier.cx + lengthdir_x(barrier.r + _off, _a), y: barrier.cy + lengthdir_y(barrier.r + _off, _a) };
}

barrier_hit = function()
{
    if (!barrier.on || barrier.broken) return;
    barrier.flash = 1;
    // a jagged crack across the band somewhere along it
    var _a = random_range(-barrier_arc * 0.85, barrier_arc * 0.85);
    var _p = barrier_point(_a, -barrier_th / 2);
    for (var k = 1; k <= 3; k++)
    {
        var _q = barrier_point(_a + random_range(-3, 3), -barrier_th / 2 + barrier_th * k / 3);
        array_push(barrier.cracks, { x1: _p.x, y1: _p.y, x2: _q.x, y2: _q.y });
        _p = _q;
    }
    var _s = audio_play_sound(snd_impact, 1, false);
    audio_sound_pitch(_s, random_range(0.9, 1.15));
    scr_camera_shake(3, 8);
}

barrier_shatter = function()
{
    if (!barrier.on || barrier.broken) return;
    barrier.broken = true;
    barrier.on = false;
    for (var i = 0; i < shard_count; i++)
    {
        var _a = random_range(-barrier_arc, barrier_arc);
        var _p = barrier_point(_a, random_range(-barrier_th / 2, barrier_th / 2));
        var _d = _a + 180 + random_range(-40, 40); // blown back towards them
        var _sp = random_range(1, 4);
        array_push(shards, { x: _p.x, y: _p.y, vx: lengthdir_x(_sp, _d), vy: lengthdir_y(_sp, _d) - random_range(0, 2),
                             rot: random(360), vr: random_range(-12, 12), len: random_range(5, 11), t: 0 });
    }
    audio_play_sound(snd_glassbreak, 1, false);
    audio_play_sound(snd_impact, 1, false);
    scr_camera_shake(6, 20);
}

/// is (_x, _y) touching the barrier?
barrier_touches = function(_x, _y, _pad)
{
    if (!barrier.on || barrier.broken) return false;
    var _d = point_distance(barrier.cx, barrier.cy, _x, _y);
    if (abs(_d - barrier.r) > barrier_th / 2 + _pad) return false;
    return abs(angle_difference(point_direction(barrier.cx, barrier.cy, _x, _y), 0)) <= barrier_arc;
}

// ------------------------------------------------------------ spades

/// a spade from King's hand to _target. _on_hit() runs when it lands
throw_spade = function(_target, _speed, _on_hit)
{
    if (!instance_exists(obj_king) || !instance_exists(_target)) return;
    var _k = body_mid(obj_king);
    var _x = _k.x + king_hand_x, _y = _k.y + king_hand_y;
    array_push(spades, { x: _x, y: _y, target: _target, speed: _speed, rot: 0, on_hit: _on_hit });
    audio_play_sound(snd_swing, 1, false);
}

spade_break = function(_x, _y)
{
    for (var i = 0; i < 5; i++)
    {
        array_push(chunks, { x: _x, y: _y, vx: random_range(1, 4), vy: random_range(-4, -1), rot: random(360), vr: random_range(-15, 15), t: 0 });
    }
}

// ------------------------------------------------------------ the scene
// { act: "name" } runs an action and waits for it, { text: "id" } opens a normal textbox and waits
// for it to close, { wait: frames } just waits.
steps = [
    { act: "first_block" },           // the Knight swoons Susie, she blocks it
    { wait: 15 },
    { text: "rk_finale_1" },          // "Nice try, as"
    { act: "susie_rapid" },           // ...faster and faster
    { act: "ralsei_barrier" },        // Ralsei's barrier; the Knight stops for a second
    { wait: 60 },
    { act: "barrier_barrage" },       // then hits it with everything
    { act: "king_spades" },           // King walks up, his cape, two spades, the barrier breaks
    { wait: 15 },
    { act: "double_swoon" },          // both swooned
    { wait: 40 },
    { text: "rk_finale_2" },          // "Enough."
    { act: "knight_leave" },          // back into the ball, to the door
    { wait: 30 },
    { act: "struggle" },              // they try to get up
    { wait: 20 },
    { text: "rk_finale_3" },          // King's lines, "C-Crap..."
    { act: "susie_getup" },           // she gets up, right a bit, down a bit
    { act: "king_counter" },          // King throws, she blocks and Rude Busters him
    { wait: 20 },
    { act: "heal_beam" },             // turns around, heals Ralsei from there
    { wait: 15 },
    { text: "rk_finale_4" },          // "Come on."
    { act: "run_inside" }             // to the door, quick fade into the next room
];

/// runs the next step once the current one's done. returns false when there's nothing left
run_steps = function()
{
    if (busy) return true;
    if (talking)
    {
        if (instance_exists(obj_textbox)) return true;
        talking = false;
    }
    if (wait_t > 0) { wait_t--; return true; }
    if (step_i >= array_length(steps)) return false;

    var _st = steps[step_i];
    step_i++;
    if (variable_struct_exists(_st, "act"))  play(_st.act);
    if (variable_struct_exists(_st, "text")) { create_textbox(_st.text); talking = true; }
    if (variable_struct_exists(_st, "wait")) wait_t = _st.wait;
    return true;
}