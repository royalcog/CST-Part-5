// rm_tower_top, Part 5: back to top-down at the top of the tower. Queen & Lancer have been waiting here,
// staring up at the Titan's face (offscreen, above the top of the screen), with Queen's empty chair parked beside them.
// Susie & Ralsei walk up from the bottom (they've just come over the edge), then self_6 opens.
// after self_6, Lancer walks over, hops on the chair, and it floats back down off the bottom of the screen.
// (same flow either way you got up here: climbing off the top of rm_tower2, or Queen's lift at 1 HP)
global.cutscene_lock = true;
global.textbox_top   = false;

// Kris is invisible but still walks around on the arrow keys: keep him put
with (obj_kris) { move_spd = 0; x = -200; y = -200; }

// --- the camera: it starts on the left (the gap in the floor, where Lancer goes down), then pans right
//     toward the Titan after "Let's end this.", ending up centred on the room for the battle ---
vw           = camera_get_view_width(view_camera[0]);
cam_start_x  = 0;
cam_battle_x = round((room_width - vw) / 2);
cam_pan_time = 70;                 // frames
cam_x        = cam_start_x;
cam_pan      = { on: false, t: 0, from: 0, to: 0, time: cam_pan_time };
set_cam = function(_x)
{
    cam_x = _x;
    camera_set_view_pos(view_camera[0], round(_x), 0);
    if (instance_exists(obj_camera_controller)) obj_camera_controller.cam_x = round(_x);   // it'd put the camera back otherwise
}
set_cam(cam_start_x);
/// pans the camera to x _to over _frames frames (eased in and out). anything can call it
pan_cam = function(_to, _frames)
{
    cam_pan = { on: true, t: 0, from: cam_x, to: _to, time: max(1, _frames) };
}

// --- tuning: where everyone stands (their feet, room px) ---
cx          = cam_start_x + vw / 2;   // the middle of the screen while they talk
bcx         = cam_battle_x + vw / 2;  // the middle of the screen in the battle
susie_x     = cx + 105;
ralsei_x    = cx + 170;
pair_y      = 250;                 // where Susie & Ralsei stop
pair_from_y = room_height + 90;    // they start below the screen
lancer_x    = cx - 10;
lancer_y    = 250;
queen_x     = cx - 95;
queen_y     = 215;                 // a bit further back than Lancer, so he can walk past in front of her
pair_walk   = 2;                   // px per frame
lancer_walk = 2;
intro_wait  = 40;                  // frames after the fade-in before they walk up
talk_wait   = 20;                  // frames after they stop before self_6

// --- tuning: poses ---
susie_left   = spr_susie_walk_left_neutral;
susie_right  = spr_susie_walk_right_neutral;
susie_up     = spr_susie_walk_up;
susie_down   = spr_susie_walk_down_neutral;
ralsei_left  = spr_ralsei_walk_left_neutral;
ralsei_right = spr_ralsei_walk_right_neutral;
ralsei_up    = spr_ralsei_walk_up;
ralsei_down  = spr_ralsei_walk_down_neutral;
lancer_left  = spr_lancer_left_sad;
lancer_right = spr_lancer_right_sad;
lancer_ride  = spr_lancer_dt_unhappy;     // once he's on the chair
queen_left   = spr_queen_walk_left_unhappy;
queen_right  = spr_queen_walk_right_unhappy;

// --- tuning: the chair (parked, empty, bobbing), on the left, flipped so its near arm faces everyone ---
chair_x      = 125;               // over the gap in the floor (x 0-240), so it can float down through it
chair_y      = lancer_y - 56;     // same height off the ground as rm_two's, so Lancer just walks straight over
chair_flip   = true;              // false: the chair faces right like rm_two's (then Lancer's hop lands on its far arm)
lancer_board = { x: chair_x + (chair_flip ? 125 : -125), y: lancer_y };   // Lancer walks here (straight left, the floor's edge), then hops on
lancer_seat  = { dx: -46, dy: 16 };                     // his feet, from the chair's origin (its near arm), same as rm_two
lancer_hop   = { frames: 24, h: 36 };
ride_wait    = 30;                 // frames he sits there before it goes
end_wait     = 40;                 // frames after it's gone before Z works again

// --- tuning: "Let's end this." -> the Titan Spawn -> the battle ---
end_walk_frames = 45;              // they get this far into walking before the Spawn stop them
end_walk_dx     = 1.5;             // px per frame (right, toward the Titan; the camera pans with them)
end_walk_dy     = 0;
spawn_spots     = [                // where the Titan Spawn end up (room px, their centre), clear of the UI boxes
    { x: bcx + 190, y: 95 },
    { x: bcx + 290, y: 165 },
    { x: bcx + 200, y: 235 },
];
spawn_after     = 50;              // frames into the walk/pan that the first one starts dropping
spawn_stagger   = 10;              // frames between each one starting to drop
spawn_from_y    = -80;             // they drop from above the screen
shock_hold      = 50;              // frames everyone's shocked before the battle starts
battle_spots    = {                // their feet in battle (room px), on the left facing the Spawn
    queen:  { x: bcx - 200, y: 145 },
    susie:  { x: bcx - 275, y: 210 },
    ralsei: { x: bcx - 265, y: 270 },
};
battle_walk     = 3;               // px per frame they walk to their spots (then draw their weapons)
battle_wait     = 15;              // frames after the draw-weapon animation before the UI comes in
queen_battle_sprite = spr_queen_walk_right_unhappy;   // same as the King fight

// --- state ---
state = "setup";
t     = 0;
chair = noone;

/// puts _o's feet on (_x, _y)
set_feet = function(_o, _x, _y)
{
    var _f = scr_get_feet(_o);
    _o.x += _x - _f.x;
    _o.y += _y - _f.y;
}

/// _o faces _spr (frame 0, not animating) without its feet moving.
/// Susie & Ralsei line up by their visible feet (some of their sprites have a spare row at the bottom)
face = function(_o, _spr)
{
    if (!instance_exists(_o)) return;
    if (_o.object_index == obj_susie || _o.object_index == obj_ralsei) scr_set_sprite_keep_body(_o, _spr);
    else scr_set_sprite_keep_feet(_o, _spr);
}

/// gets (or makes) one of _obj, standing still on _spr with its feet on (_x, _y)
place = function(_obj, _spr, _x, _y)
{
    var _o = instance_exists(_obj) ? instance_find(_obj, 0) : instance_create_layer(0, 0, "Instances", _obj);
    _o.sprite_index = _spr;
    _o.last_sprite  = _spr;   // placed by hand, so scr_auto_keep_feet leaves it alone
    _o.image_index  = 0;
    _o.image_speed  = 0;
    _o.anim_loop    = true;
    _o.image_alpha  = 1;
    _o.visible      = true;
    set_feet(_o, _x, _y);
    return _o;
}

unlock = function() { global.cutscene_lock = false; }

// --- tuning: Susie & Ralsei patch each other up once they're up (before self_6) ---
heal_full         = { susie: 290, ralsei: 210 };   // their max HP (the climb's)
susie_heal_frame  = 14;   // frame of spr_susie_heal the heal leaves on
ralsei_heal_frame = 6;    // frame of spr_ralsei_spell his lands on
heal_hold         = 50;   // frames after both land before they turn back

/// _o goes to _spr facing _xs (2 = the sprite's own way, -2 = flipped) without its body moving
pose_flip = function(_o, _spr, _xs)
{
    if (!instance_exists(_o)) return;
    with (_o)
    {
        var _bx = x + ((sprite_get_bbox_left(sprite_index) + sprite_get_bbox_right(sprite_index) + 1) / 2 - sprite_get_xoffset(sprite_index)) * image_xscale;
        var _by = y + (sprite_get_bbox_bottom(sprite_index) + 1 - sprite_get_yoffset(sprite_index)) * image_yscale;
        image_xscale = _xs;
        sprite_index = _spr;
        last_sprite  = _spr;
        image_index  = 0;
        x = _bx - ((sprite_get_bbox_left(_spr) + sprite_get_bbox_right(_spr) + 1) / 2 - sprite_get_xoffset(_spr)) * image_xscale;
        y = _by - (sprite_get_bbox_bottom(_spr) + 1 - sprite_get_yoffset(_spr)) * image_yscale;
    }
}

/// a heal lands on _o: snd_heal, a green flash, their HP back (the amount in green, or MAX if they were full)
heal_land = function(_o, _key)
{
    if (!variable_global_exists("plat_hp") || !is_struct(global.plat_hp)) global.plat_hp = { susie: heal_full.susie, ralsei: heal_full.ralsei };
    var _gain = heal_full[$ _key] - global.plat_hp[$ _key];
    global.plat_hp[$ _key] = heal_full[$ _key];
    audio_play_sound(snd_heal, 1, false);
    var _i = instance_find(_o, 0);
    var _f = instance_create_depth(0, 0, _i.depth - 1, obj_heal_flash);
    _f.target   = _o;
    _f.duration = 40;
    var _top = (sprite_get_bbox_top(_i.sprite_index) - sprite_get_yoffset(_i.sprite_index)) * _i.image_yscale - 6;
    scr_trigger_damage_popup(_i, (_gain > 0) ? _gain : "MAX", c_lime, c_lime, 0, _top, noone);
}

/// Susie heals Ralsei while Ralsei heals Susie, then they turn back and _then runs
heal_each_other = function(_then)
{
    heal_then    = _then;
    heals_landed = 0;
    // they face each other (Susie's heal faces left, Ralsei's spell faces right: both flipped)
    pose_flip(obj_susie,  spr_susie_heal,   -2);
    pose_flip(obj_ralsei, spr_ralsei_spell, -2);
    with (obj_susie)  { image_speed = 1; anim_loop = false; charge_snd = scr_audio_fade_in(snd_charge, 600, 1, true); }
    with (obj_ralsei) { image_speed = 1; anim_loop = false; }

    heal_one_done = function()
    {
        heals_landed++;
        if (heals_landed < 2) return;
        scr_call_after_frames(function()
        {
            with (obj_susie) audio_sound_gain(charge_snd, 0, 300);
            scr_call_after_frames(function() { audio_stop_sound(obj_susie.charge_snd); }, 20);
            pose_flip(obj_susie,  susie_left,  2);
            pose_flip(obj_ralsei, ralsei_left, 2);
            with (obj_susie)  { image_speed = 0; anim_loop = true; }
            with (obj_ralsei) { image_speed = 0; anim_loop = true; }
            heal_then();
        }, heal_hold);
    };
    scr_call_on_anim_frame(obj_susie,  spr_susie_heal,   susie_heal_frame,  function() { heal_land(obj_ralsei, "ralsei"); heal_one_done(); });
    scr_call_on_anim_frame(obj_ralsei, spr_ralsei_spell, ralsei_heal_frame, function() { heal_land(obj_susie,  "susie");  heal_one_done(); });
}

/// Susie & Ralsei walk up from the bottom; once they're both there, Queen turns to them and self_6 opens
pair_enter = function()
{
    arrived = 0;
    var _done = function()
    {
        arrived++;
        if (arrived < 2) return;
        face(obj_lancer, lancer_right);   // Lancer & Queen turn to them
        face(obj_queen,  queen_right);
        // Susie & Ralsei patch each other up after the climb, then self_6
        heal_each_other(function()
        {
            scr_call_after_frames(function()
            {
                create_textbox("self_6");
                global.dialogue_self = 6;   // so the next Z opens self_7
            }, talk_wait);
        });
    };
    scr_walk_feet_to(obj_susie,  susie_left,  susie_right,  susie_up,  susie_down,  susie_x,  pair_y, pair_walk, _done);
    scr_walk_feet_to(obj_ralsei, ralsei_left, ralsei_right, ralsei_up, ralsei_down, ralsei_x, pair_y, pair_walk, _done);
}

/// after self_6: Lancer walks over in front of Queen, hops on the chair, and down it goes
lancer_leave = function()
{
    if (!instance_exists(chair)) { unlock(); return; }
    face(obj_queen, queen_left);   // she watches him go
    scr_walk_feet_to(obj_lancer, lancer_left, lancer_right, spr_lancer_up, spr_lancer_down, lancer_board.x, lancer_board.y, lancer_walk,
        function()
        {
            chair.add_rider(obj_lancer, lancer_seat.dx, lancer_seat.dy, lancer_hop.frames, lancer_hop.h, lancer_ride,
                function()
                {
                    scr_call_after_frames(function()
                    {
                        // everyone looks down after him
                        face(obj_susie,  susie_down);
                        face(obj_ralsei, ralsei_down);
                        face(obj_queen,  spr_queen_walk_down_unhappy);
                        if (instance_exists(chair)) chair.liftoff(function() { scr_call_after_frames(function() { unlock(); }, end_wait); }, 1);
                        else unlock();
                    }, ride_wait);
                });
        });
}

// ---------------------------------------------------------------- self_7
/// after "Let's end this.": all three start walking toward the Titan... and the Titan Spawn drop in
end_this = function()
{
    scr_char_move_now(obj_susie,  susie_right, true, end_walk_dx, end_walk_dy, 1, end_walk_frames);
    scr_char_move_now(obj_ralsei, ralsei_right, true, end_walk_dx, end_walk_dy, 1, end_walk_frames);
    scr_char_move_now(obj_queen,  queen_right, true, end_walk_dx, end_walk_dy, 1, end_walk_frames);
    pan_cam(cam_battle_x, cam_pan_time);
    spawns = [];
    for (var i = 0; i < array_length(spawn_spots); i++)
    {
        var _s = instance_create_depth(spawn_spots[i].x, spawn_from_y, -2000, obj_battle_titanspawn);
        _s.home_x = spawn_spots[i].x;
        _s.home_y = spawn_spots[i].y;
        _s.drop_delay = spawn_after + i * spawn_stagger;
        array_push(spawns, _s);
    }
    state = "spawns";
    t = 0;
}

/// they all stop: Susie & Ralsei shocked, Queen turns to face them
spawn_shock = function()
{
    scr_set_sprite_keep_body(obj_susie,  spr_susie_shocked);
    scr_set_sprite_keep_body(obj_ralsei, spr_ralsei_shocked);
    face(obj_queen, queen_right);
    with (obj_susie)  { image_speed = 0; image_index = 0; }
    with (obj_ralsei) { image_speed = 0; image_index = 0; }
    // the climb's song cuts out the moment they land (the battle's own song starts with the battle)
    audio_stop_sound(sng_chaostower);
    global.song = noone;
}

/// everyone walks to their battle spot (walking animation, the way they're going), then Susie & Ralsei draw their weapons
battle_slide_start = function()
{
    // Susie & Ralsei's battle sprites line up by their origin (they're in keep_feet_skip), so they walk their
    // x/y straight to where it'll be in battle: then nothing moves when the draw-weapon and idle sprites swap in.
    // Queen walks by her feet as usual.
    var _sp = scr_feet_to_xy(obj_susie,  spr_susie_battle_idle,  battle_spots.susie.x,  battle_spots.susie.y);
    var _rp = scr_feet_to_xy(obj_ralsei, spr_ralsei_battle_idle, battle_spots.ralsei.x, battle_spots.ralsei.y);
    walkers = [
        { o: obj_susie,  to: _sp,                 by_origin: true,  l: susie_left,  r: susie_right,  done: false },
        { o: obj_ralsei, to: _rp,                 by_origin: true,  l: ralsei_left, r: ralsei_right, done: false },
        { o: obj_queen,  to: battle_spots.queen,  by_origin: false, l: queen_left,  r: queen_right,  done: false },
    ];
    for (var i = 0; i < 3; i++)
    {
        var _w = walkers[i];
        var _f = _w.by_origin ? { x: _w.o.x, y: _w.o.y } : scr_get_feet(_w.o);
        _w.o.sprite_index = (_w.to.x < _f.x) ? _w.l : _w.r;
        _w.o.last_sprite  = _w.o.sprite_index;   // don't let End Step nudge them for the swap
        _w.o.image_speed  = 1;
        _w.o.anim_loop    = true;
    }
    state = "battle_slide";
    t = 0;
}

/// Susie & Ralsei draw their weapons (the King fight's intro), then idle
battle_draw = function()
{
    with (obj_susie)  { sprite_index = spr_susie_battle_intro;  image_index = 0; image_speed = 1; anim_loop = false; }
    with (obj_ralsei) { sprite_index = spr_ralsei_battle_intro; image_index = 0; image_speed = 1; anim_loop = false; }
    audio_play_sound(snd_taking_out_sword, 1, false);
    state = "battle_draw";
    t = 0;
}

// ---------------------------------------------------------------- after the battle
// weapons away -> everyone regroups -> self_8 (Ralsei offers) -> Ralsei heals all three to max
// -> self_9 (Susie's "outside of battles" talk) -> they walk forward a little -> titan_reveal()

// --- tuning ---
regroup_spots = {                 // their feet once they regroup (room px)
    queen:  { x: bcx - 150, y: 215 },
    susie:  { x: bcx - 40,  y: 250 },
    ralsei: { x: bcx + 25,  y: 250 },
};
regroup_walk      = 2;            // px per frame
regroup_pause     = 20;           // frames after the battle UI's gone before they walk
after_regroup     = 20;           // frames after they're in place before self_8
party_heal_frame  = 6;            // frame of spr_ralsei_spell the heal leaves on (same as the climb heal)
party_heal_hold   = 50;           // frames after it lands before he lowers his arms
after_heal        = 20;           // frames before self_9
forward_dx        = 1;            // px per frame they walk forward after self_9 (right, toward the Titan): 180px
forward_dy        = 0;
forward_frames    = 180;
forward_cam_pan   = true;         // the camera pans right to where the Titan comes in, while they walk...
forward_cam_dist  = 270;          // ...this far (the camera starts at 324, the room's right edge is at 647)...
forward_cam_time  = 180;          // ...over this many frames (eased)
forward_pause     = 20;           // frames after they stop before titan_reveal()
putaway_speed     = 12 / 60;      // frames per frame they play their draw-weapon animations backwards at (the sprites' 12fps)

/// Susie & Ralsei put their weapons away (their draw-weapon animations, backwards), then they're back in their
/// walk sprites and _then runs. the battle sprites are origin-aligned with the walk sprites, so it's a straight swap
victory_walk_dx   = { susie: -6, ralsei: -2 };   // sprite px: their victory pose's last frame stands a little off from
                                                 // where their walk sprite does, so this lines their bodies up on the swap

/// Susie & Ralsei put their weapons away, then they're back in their walk sprites and _then runs.
/// anyone who just did their victory pose already put theirs away at the end of it: they just swap to walking.
/// anyone else plays their draw-weapon animation backwards (battle sprites are origin-aligned with the walk sprites)
put_away = function(_then)
{
    putaway_list = [];
    var _who = [
        { o: obj_susie,  victory: spr_susie_victory,  intro: spr_susie_battle_intro,  walk: susie_right,  dx: victory_walk_dx.susie },
        { o: obj_ralsei, victory: spr_ralsei_victory, intro: spr_ralsei_battle_intro, walk: ralsei_right, dx: victory_walk_dx.ralsei },
    ];
    for (var i = 0; i < array_length(_who); i++)
    {
        var _w = _who[i];
        if (!instance_exists(_w.o)) continue;
        if (_w.o.sprite_index == _w.victory)
        {
            with (_w.o) { x += _w.dx * image_xscale; sprite_index = _w.walk; last_sprite = _w.walk; image_index = 0; image_speed = 0; anim_loop = true; }
        }
        else
        {
            with (_w.o) { sprite_index = _w.intro; last_sprite = _w.intro; image_speed = 0; anim_loop = true; image_index = image_number - 1; }
            array_push(putaway_list, _w);
        }
    }
    putaway_then = _then;
    state = "putaway";
    t = 0;
}
/// the battle's won (obj_battle_menu.on_win): weapons away, then everyone walks back together
after_battle = function()
{
    global.cutscene_lock = true;
    face(obj_queen, queen_right);
    put_away(function() { regroup(); });
}

/// everyone walks back into a line, then self_8
regroup = function()
{
    scr_call_after_frames(function()
    {
        regrouped = 0;
        var _done = function()
        {
            regrouped++;
            if (regrouped < 3) return;
            face(obj_queen,  queen_right);
            face(obj_susie,  susie_right);
            face(obj_ralsei, ralsei_right);   // everyone faces forward, and stays that way through the talk
            scr_call_after_frames(function()
            {
                create_textbox("self_8");
                global.dialogue_self = 8;
            }, after_regroup);
        };
        scr_walk_feet_to(obj_queen,  queen_left,  queen_right,  spr_queen_walk_up, spr_queen_walk_down_unhappy, regroup_spots.queen.x,  regroup_spots.queen.y,  regroup_walk, _done);
        scr_walk_feet_to(obj_susie,  susie_left,  susie_right,  susie_up,  susie_down,  regroup_spots.susie.x,  regroup_spots.susie.y,  regroup_walk, _done);
        scr_walk_feet_to(obj_ralsei, ralsei_left, ralsei_right, ralsei_up, ralsei_down, regroup_spots.ralsei.x, regroup_spots.ralsei.y, regroup_walk, _done);
    }, regroup_pause);
}

/// a heal lands on _o: snd_heal, green flash, HP back to max (the amount in green, or MAX if they were full)
party_heal_land = function(_o, _name)
{
    if (!instance_exists(_o)) return;
    var _gain = 0;
    if (variable_global_exists("post_battle_hp") && is_struct(global.post_battle_hp) && variable_struct_exists(global.post_battle_hp, _name))
    {
        var _h = global.post_battle_hp[$ _name];
        _gain = max(0, _h.max_hp - _h.hp);
        _h.hp = _h.max_hp;
    }
    var _i = instance_find(_o, 0);
    var _f = instance_create_depth(0, 0, _i.depth - 1, obj_heal_flash);
    _f.target   = _i;
    _f.duration = 40;
    var _top = (sprite_get_bbox_top(_i.sprite_index) - sprite_get_yoffset(_i.sprite_index)) * _i.image_yscale - 6;
    scr_trigger_damage_popup(_i, (_gain > 0) ? _gain : "MAX", c_lime, c_lime, 0, _top, noone);
}

party_heal_speed  = 8 / 60;        // frames per frame his spell animation plays at (the sprite's 8fps)

/// after self_8: Ralsei casts facing right, everyone's healed at once, he goes back to standing, then self_9.
/// the scene steps his frames itself (state "party_heal" in Step), so nothing else can freeze him partway
ralsei_heal_all = function()
{
    pose_flip(obj_ralsei, spr_ralsei_spell, 2);    // faces right on its own
    with (obj_ralsei) { image_speed = 0; image_index = 0; anim_loop = true; }
    party_heal_landed = false;
    state = "party_heal";
    t = 0;
}

/// (from Step) his spell's played out and he's held it: back to his right neutral sprite, then self_9
party_heal_end = function()
{
    pose_flip(obj_ralsei, ralsei_right, 2);
    with (obj_ralsei) { image_speed = 0; image_index = 0; anim_loop = true; }
    state = "after_heal";
    t = 0;
    scr_call_after_frames(function()
    {
        create_textbox("self_9");
        global.dialogue_self = 9;
    }, after_heal);
}

/// after self_9: all three walk forward a little, then the Titan reveal
walk_forward = function()
{
    scr_char_move_now(obj_susie,  susie_right,  true, forward_dx, forward_dy, 1, forward_frames);
    scr_char_move_now(obj_ralsei, ralsei_right, true, forward_dx, forward_dy, 1, forward_frames);
    scr_char_move_now(obj_queen,  queen_right,  true, forward_dx, forward_dy, 1, forward_frames);
    if (forward_cam_pan) pan_cam(cam_x + forward_cam_dist, forward_cam_time);
    scr_call_after_frames(function()
    {
        face(obj_susie,  susie_right);
        face(obj_ralsei, ralsei_right);
        face(obj_queen,  queen_right);
        scr_call_after_frames(function() { titan_reveal(); }, forward_pause);
    }, forward_frames + 2);
}

// ---------------------------------------------------------------- the Titan reveal (obj_titan_reveal)
// black-out -> crescent (holds) -> [titan_talk_case, if set] -> the wings open -> titan_after_reveal()

// --- tuning ---
titan_talk_case  = "";            // "" = no talk: the crescent just holds for titan_hold frames, then it opens.
                                  // set to a self_ case to talk while the crescent's up: end that case with
                                  //   scr_custom_call_after_textbox_delayed(function() { with (obj_tower_top_scene) titan_open(); }, 0);
titan_talk_self  = 0;             // that case's number (so the next Z after it is right)
titan_talk_wait  = 30;            // frames after the crescent's in before the talk opens
titan_hold       = 120;           // frames the crescent holds when there's no talk
titan            = noone;

titan_reveal = function()
{
    with (obj_titan_reveal) instance_destroy();
    titan = instance_create_depth(0, 0, 25, obj_titan_reveal);
    titan.on_crescent_done = function()
    {
        if (titan_talk_case != "")
            scr_call_after_frames(function()
            {
                create_textbox(titan_talk_case);
                global.dialogue_self = titan_talk_self;
            }, titan_talk_wait);
        else
            scr_call_after_frames(function() { titan_open(); }, titan_hold);
    };
    titan.on_open_done = function() { titan_after_reveal(); };
    titan.blackout();
}

/// the wings open (call this from the end of the talk while the crescent's up)
titan_open = function()
{
    if (instance_exists(titan)) titan.open();
}

// ---------------------------------------------------------------- the ambush (after the Titan's wings open)
// self_10 ("Are you guys ready?" ... Lancer: "I'm back!") -> everyone turns round -> self_11 (cut off) -> spades from the
// Titan's side knock Susie & Ralsei down (Queen's shield catches hers) -> the camera pans left: Lancer, with King ->
// self_12 -> spades from above + one from the front: knocked down again and shoved right (Queen's shield swings round)
// -> King & Lancer walk up, the camera pans to the fight's spot -> self_13 -> everyone readies -> King's cape + laugh ->
// scr_titan_battle_start()
// every spot below is in screen px from where the camera is at that moment (so it all moves if the camera does)

// --- tuning: the camera ---
ambush_pan_dist  = 280;           // px the camera pans left to show King + Lancer (from where it is after the reveal)
ambush_pan_time  = 120;
fight_cam_dx     = 160;           // then for the fight it ends up this far back right of that
fight_pan_time   = 100;

// --- tuning: where King + Lancer stand (screen px, their feet) ---
king_start       = { x: 85,  y: 250 };   // when the camera pans over to them
lancer_start     = { x: 180, y: 262 };
king_fight       = { x: 90,  y: 245 };   // where they walk up to for the fight (clear of the UI boxes, back from the party)
lancer_fight     = { x: 185, y: 268 };
king_walk        = 2;
// --- tuning: where the party lands after the second hit (screen px, their feet): one column, in the middle between
//     King and the Titan, Queen at the back, then Susie, then Ralsei at the front (still clear of the UI boxes) ---
party_land_x     = 430;
queen_land_y     = 150;
susie_land_y     = 210;
ralsei_land_y    = 270;
land_time        = 22;            // frames they're shoved over
land_hop         = 18;            // px

// --- tuning: the spades ---
spade_scale      = 1.5;
spade_spin       = 25;            // degrees per frame
spade_speed      = 14;            // px per frame (from the front)
spade_back_speed = 32;            // px per frame (the first wave, from behind: the Titan's side)
spade_fall_speed = 12;            // px per frame (from above)
spade_delay      = 12;            // frames after the cut-off before the first wave flies in
shield_build_every = 1;           // Queen's shield builds this fast here (frames per piece; her DEFEND's is 3)
knock_dx         = -36;           // px the first wave knocks Susie & Ralsei forward (left: they're facing left)
knock_time       = 16;
knock_hop        = 14;
ambush_hold      = 50;            // frames after the first wave before the camera pans over
reveal_hold      = 30;            // frames after the pan before self_12
approach_hold    = 30;            // frames after the second wave before King + Lancer walk up
talk_hold        = 25;
spade_hit_sounds = [snd_impact, snd_hurt];

// --- tuning: getting ready, King's cape + laugh ---
ready_hold       = 30;            // frames after they ready before his cape comes
laugh_time       = 90;            // frames he laughs for
battle_hold      = 90;            // frames after the laugh before the battle starts

// --- tuning: poses (which way each sprite faces as drawn: 1 right, -1 left) ---
susie_down_spr   = spr_susie_landed;      susie_down_native  = -1;
ralsei_down_spr  = spr_ralsei_fall_wince; ralsei_down_native = 1;
susie_shock_spr  = spr_susie_shocked;     susie_shock_native = 1;
ralsei_shock_spr = spr_ralsei_shocked;    ralsei_shock_native = 1;
king_walk_r      = spr_king_walk_right;
lancer_stand     = spr_lancer_battle;     // standing (frame 0; frame 1 when he apologises to Susie)
lancer_walk_r    = spr_lancer_right_sad;  // walking up

// --- state ---
spades = [];
chunks = [];
slides = [];
king   = noone;
lancer = noone;

/// _o into _spr facing _dir (-1 left, 1 right), body kept where it is. _native: which way _spr faces as drawn
pose_dir = function(_o, _spr, _native, _dir)
{
    pose_flip(_o, _spr, 2 * _native * _dir);
}

/// a spinning spade from (_x, _y) to (_tx, _ty) at _spd px a frame, after _delay frames. _on_hit() runs when it lands
add_spade = function(_x, _y, _tx, _ty, _spd, _delay, _on_hit)
{
    array_push(spades, { x: _x, y: _y, tx: _tx, ty: _ty, spd: _spd, delay: _delay, rot: random(360), on_hit: _on_hit, thrown: false });
}

/// a spade breaking apart where it landed
spade_break = function(_x, _y)
{
    repeat (5) array_push(chunks, { x: _x, y: _y, vx: random_range(-3, 3), vy: random_range(-4, -1), rot: random(360), vr: random_range(-15, 15), t: 0 });
}

/// the middle of _o's body (room px)
body_mid = function(_o)
{
    var _i = instance_find(_o, 0);
    var _b = scr_get_body(_i);
    var _top = _i.y + (sprite_get_bbox_top(_i.sprite_index) - sprite_get_yoffset(_i.sprite_index)) * _i.image_yscale;
    return { x: _b.x, y: (_b.y + _top) / 2 };
}

/// shoves _o by (_dx, _dy) over _frames, hopping _hop px. keeps whatever pose it's in
slide = function(_o, _dx, _dy, _frames, _hop)
{
    var _i = instance_find(_o, 0);
    if (_i == noone) return;
    // (one at a time: a new shove on the same thing replaces the old one)
    for (var i = array_length(slides) - 1; i >= 0; i--) if (slides[i].o == _i) array_delete(slides, i, 1);
    array_push(slides, { o: _i, dx: _dx, dy: _dy, frames: max(1, _frames), hop: _hop, t: 0, px: 0, py: 0 });
}

/// a spade hits _o: down (in their knocked-down pose, facing left), shoved by _dx
spade_hit = function(_o, _dx, _frames, _hop)
{
    for (var i = 0; i < array_length(spade_hit_sounds); i++) audio_play_sound(spade_hit_sounds[i], 1, false);
    scr_camera_shake(4, 10);
    if (_o == obj_susie)  pose_dir(obj_susie,  susie_down_spr,  susie_down_native,  -1);
    if (_o == obj_ralsei) pose_dir(obj_ralsei, ralsei_down_spr, ralsei_down_native, -1);
    with (_o) { image_speed = 0; image_index = 0; anim_loop = true; }
    if (_dx != 0) slide(_o, _dx, 0, _frames, _hop);   // (no shove: leave any shove that's already going alone)
}

/// the Titan's wings are open: a beat, then self_10
titan_after_reveal = function()
{
    scr_call_after_frames(function()
    {
        create_textbox("self_10");
        global.dialogue_self = 10;
    }, talk_hold);
}

/// after self_10 (Lancer, offscreen: "I'm back!"): everyone turns round to the left, then self_11
ambush_turn = function()
{
    face(obj_susie,  susie_left);
    face(obj_ralsei, ralsei_left);
    face(obj_queen,  queen_left);
    scr_call_after_frames(function()
    {
        create_textbox("self_11");
        global.dialogue_self = 11;
    }, talk_hold);
}

/// after self_11 (cut off): Queen throws her shield up behind her, spades fly in from the Titan's side
ambush_first = function()
{
    depth = -5000;   // the spades draw over everyone
    // King + Lancer are already standing over there (off the left of the screen until the camera pans)
    var _cam_after = cam_x - ambush_pan_dist;
    king   = place(obj_king,   king_walk_r,  _cam_after + king_start.x,   king_start.y);
    lancer = place(obj_lancer, lancer_stand, _cam_after + lancer_start.x, lancer_start.y);

    // her shield, quick, on her right (behind her: she's facing left)
    with (obj_queen_shield) instance_destroy();
    with (instance_create_depth(0, 0, 0, obj_queen_shield)) { section_every = other.shield_build_every; side = 1; side_k = 1; follow_queen(); }

    var _sx = cam_x + vw + 40;   // in from the right edge (the Titan's side)
    var _s = body_mid(obj_susie), _r = body_mid(obj_ralsei);
    add_spade(_sx, _s.y, _s.x, _s.y, spade_back_speed, spade_delay,     function() { spade_hit(obj_susie,  knock_dx, knock_time, knock_hop); });
    add_spade(_sx, _r.y, _r.x, _r.y, spade_back_speed, spade_delay + 4, function() { spade_hit(obj_ralsei, knock_dx, knock_time, knock_hop); });
    // Queen's hits her shield
    var _q  = body_mid(obj_queen);
    var _sh = instance_find(obj_queen_shield, 0);
    var _qx = (_sh != noone) ? _sh.x + sprite_get_width(spr_queen_shield) * _sh.scale / 2 : _q.x;
    add_spade(_sx, _q.y, _qx, _q.y, spade_back_speed, spade_delay + 2, function()
    {
        audio_play_sound(snd_impact, 1, false);
        with (obj_queen_shield) flash = 1;
    });

    // then the camera pans over to them
    var _wait = ceil((vw + 40) / spade_back_speed) + spade_delay + 4 + ambush_hold;
    scr_call_after_frames(function()
    {
        pan_cam(cam_x - ambush_pan_dist, ambush_pan_time);
        scr_call_after_frames(function()
        {
            create_textbox("self_12");
            global.dialogue_self = 12;
        }, ambush_pan_time + reveal_hold);
    }, _wait);
}

/// self_12, "You already lost this fight, asshole.": Susie's up, axe out at King
susie_challenge = function()
{
    pose_dir(obj_susie, spr_susie_attack_ready, 1, -1);
    with (obj_susie) { image_speed = 0; image_index = 0; anim_loop = true; }
    audio_play_sound(snd_swing, 1, false);
}

/// after self_12 ("Foolish Lightner."): a spade over Susie and one over Ralsei, one coming at them from the front, one at
/// Queen from the front. they guard; the ones from above knock them down, the one from the front shoves them right
ambush_second = function()
{
    pose_dir(obj_susie,  spr_susie_defend,  1, -1);
    pose_dir(obj_ralsei, spr_ralsei_defend, 1, -1);
    with (obj_susie)  { image_speed = 0; image_index = 0; anim_loop = true; }
    with (obj_ralsei) { image_speed = 1; image_index = 0; anim_loop = false; }
    // Queen's shield swings round in front of her (built again if it's gone)
    if (!instance_exists(obj_queen_shield)) with (instance_create_depth(0, 0, 0, obj_queen_shield)) { section_every = other.shield_build_every; follow_queen(); }
    with (obj_queen_shield) side = -1;

    // where they'll end up (the camera's about to move: these are from where it'll be)
    var _cam_fight = cam_x + fight_cam_dx;
    var _sb = scr_get_body(instance_find(obj_susie, 0)), _rb = scr_get_body(instance_find(obj_ralsei, 0));
    var _sdx = _cam_fight + party_land_x - _sb.x, _sdy = susie_land_y  - _sb.y;
    var _rdx = _cam_fight + party_land_x - _rb.x, _rdy = ralsei_land_y - _rb.y;
    var _qf  = scr_get_feet(instance_find(obj_queen, 0));
    var _qdx = _cam_fight + party_land_x - _qf.x, _qdy = queen_land_y - _qf.y;
    land = { sdx: _sdx, sdy: _sdy, rdx: _rdx, rdy: _rdy, qdx: _qdx, qdy: _qdy };

    // from above
    var _s = body_mid(obj_susie), _r = body_mid(obj_ralsei);
    var _top = camera_get_view_y(view_camera[0]) - 40;
    add_spade(_s.x, _top, _s.x, _s.y - 20, spade_fall_speed, 0, function() { spade_hit(obj_susie,  0, 1, 0); });
    add_spade(_r.x, _top, _r.x, _r.y - 20, spade_fall_speed, 2, function() { spade_hit(obj_ralsei, 0, 1, 0); });
    // from the front (King's side): it shoves them both right, onto their spots
    var _kx = instance_exists(king) ? body_mid(obj_king).x : cam_x - 40;
    var _fy = (_s.y + _r.y) / 2;
    add_spade(_kx, _fy, min(_s.x, _r.x), _fy, spade_speed + 2, 6, function()
    {
        for (var i = 0; i < array_length(spade_hit_sounds); i++) audio_play_sound(spade_hit_sounds[i], 1, false);
        scr_camera_shake(6, 14);
        slide(obj_susie,  land.sdx, land.sdy, land_time, land_hop);
        slide(obj_ralsei, land.rdx, land.rdy, land_time, land_hop);
    });
    // and one at Queen's shield, from the front (it slides her back too, but she stays standing)
    var _q = body_mid(obj_queen);
    add_spade(_kx, _q.y, _q.x - 60, _q.y, spade_speed + 2, 8, function()
    {
        audio_play_sound(snd_impact, 1, false);
        with (obj_queen_shield) flash = 1;
        slide(obj_queen, land.qdx, land.qdy, land_time, 0);
    });

    // then King + Lancer walk up, the camera following
    var _far = max(abs(_kx - min(_s.x, _r.x)), abs(_kx - _q.x));
    scr_call_after_frames(function() { approach(); }, ceil(_far / (spade_speed + 2)) + 8 + land_time + approach_hold);
}

/// King + Lancer walk up to their fight spots, the camera pans to the fight's spot, then self_13
approach = function()
{
    var _cam_fight = cam_x + fight_cam_dx;
    pan_cam(_cam_fight, fight_pan_time);
    arrived = 0;
    var _done = function()
    {
        arrived++;
        if (arrived < 2) return;
        face(obj_king, king_walk_r);
        face(obj_lancer, lancer_stand);
        with (obj_lancer) image_index = 1;   // still hanging his head (since "I'm so sorry, Susie...")
        scr_queen_shield_takedown();
        scr_call_after_frames(function()
        {
            create_textbox("self_13");
            global.dialogue_self = 13;
        }, talk_hold);
    };
    scr_walk_feet_to(obj_king,   king_walk_r,   king_walk_r,   king_walk_r,   king_walk_r,   _cam_fight + king_fight.x,   king_fight.y,   king_walk, _done);
    scr_walk_feet_to(obj_lancer, lancer_walk_r, lancer_walk_r, lancer_walk_r, lancer_walk_r, _cam_fight + lancer_fight.x, lancer_fight.y, king_walk, _done);
}

/// after self_13: all three ready toward King + Lancer, then King's cape flies onto him and he laughs
ready_up = function()
{
    pose_dir(obj_susie,  spr_susie_attack_ready,  1, -1);
    pose_dir(obj_ralsei, spr_ralsei_attack_ready, 1, -1);
    pose_dir(obj_queen,  spr_queen_pie_throw,     1, -1);
    with (obj_susie)  { image_speed = 0; image_index = 0; anim_loop = true; }
    with (obj_ralsei) { image_speed = 0; image_index = 0; anim_loop = true; }
    with (obj_queen)  { image_speed = 0; image_index = 0; }
    audio_play_sound(snd_taking_out_sword, 1, false);
    scr_call_after_frames(function() { king_cape(); }, ready_hold);
}

/// his cape flies in from the left onto his back (the dark screen), then he laughs, then the battle
king_cape = function()
{
    if (!instance_exists(obj_king)) { scr_titan_battle_start(); return; }
    var _c = instance_create_depth(cam_x - 60, obj_king.y + 37, -99999, obj_king_cape);
    _c.image_xscale  = -2;   // he's facing right: everything's mirrored from the King fight
    _c.back_offset_x = sprite_get_width(obj_king.sprite_index) * 2 - 46;
    _c.laugh = false;
    _c.on_merge = function()
    {
        pose_flip(obj_king, spr_king_laugh, -2);   // his battle sprites face left as drawn
        with (obj_king) image_speed = 1;
        audio_play_sound(snd_kinglaugh, 1, false);
        scr_call_after_frames(function()
        {
            pose_flip(obj_king, spr_king_battle_idle, -2);
            with (obj_king) image_speed = 1;
            scr_call_after_frames(function()
            {
                state = "titan_battle";
                with (obj_lancer) image_index = 0;   // back to his first frame for the fight
                scr_titan_battle_start();
            }, battle_hold);
        }, laugh_time);
    };
    audio_play_sound(snd_wing, 1, false);
}