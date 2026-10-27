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
cam_pan      = { on: false, t: 0, from: 0, to: 0 };
set_cam = function(_x)
{
    cam_x = _x;
    camera_set_view_pos(view_camera[0], round(_x), 0);
    if (instance_exists(obj_camera_controller)) obj_camera_controller.cam_x = round(_x);   // it'd put the camera back otherwise
}
set_cam(cam_start_x);

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
spawn_spots     = [                // where the Titan Spawn end up (room px), over the clouds on the right
    { x: bcx + 190, y: 175 },
    { x: bcx + 290, y: 245 },
    { x: bcx + 200, y: 315 },
];
spawn_after     = 50;              // frames into the walk/pan that the first one starts dropping
spawn_stagger   = 10;              // frames between each one starting to drop
spawn_from_y    = -80;             // they drop from above the screen
shock_hold      = 50;              // frames everyone's shocked before the battle starts
battle_spots    = {                // their feet in battle (room px), on the left facing the Spawn
    queen:  { x: bcx - 200, y: 215 },
    susie:  { x: bcx - 275, y: 280 },
    ralsei: { x: bcx - 265, y: 340 },
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

/// Susie & Ralsei walk up from the bottom; once they're both there, Queen turns to them and self_6 opens
pair_enter = function()
{
    arrived = 0;
    var _done = function()
    {
        arrived++;
        if (arrived < 2) return;
        face(obj_susie,  susie_left);
        face(obj_ralsei, ralsei_left);
        face(obj_lancer, lancer_right);   // Lancer & Queen turn to them
        face(obj_queen,  queen_right);
        scr_call_after_frames(function()
        {
            create_textbox("self_6");
            global.dialogue_self = 6;   // so the next Z opens self_7
        }, talk_wait);
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
    cam_pan = { on: true, t: 0, from: cam_x, to: cam_battle_x };
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