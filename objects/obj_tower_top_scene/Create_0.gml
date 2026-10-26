// rm_tower_top, Part 5: back to top-down at the top of the tower. Queen & Lancer have been waiting here,
// staring up at the Titan's face (offscreen, above the top of the screen), with Queen's empty chair parked beside them.
// Susie & Ralsei walk up from the bottom (they've just come over the edge), then self_6 opens.
// after self_6, Lancer walks over, hops on the chair, and it floats back down off the bottom of the screen.
// (same flow either way you got up here: climbing off the top of rm_tower2, or Queen's lift at 1 HP)
global.cutscene_lock = true;
global.textbox_top   = false;

// Kris is invisible but still walks around on the arrow keys: keep him put
with (obj_kris) { move_spd = 0; x = -200; y = -200; }

// --- tuning: where everyone stands (their feet, room px) ---
cx          = room_width / 2;
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
chair_x      = cx - 240;
chair_y      = lancer_y - 56;     // same height off the ground as rm_two's, so Lancer just walks straight over
chair_flip   = true;              // false: the chair faces right like rm_two's (then Lancer's hop lands on its far arm)
lancer_board = { x: chair_x + (chair_flip ? 110 : -110), y: lancer_y };   // Lancer walks here (straight left), then hops on
lancer_seat  = { dx: -46, dy: 16 };                     // his feet, from the chair's origin (its near arm), same as rm_two
lancer_hop   = { frames: 24, h: 36 };
ride_wait    = 30;                 // frames he sits there before it goes
end_wait     = 40;                 // frames after it's gone before Z works again

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
        scr_call_after_frames(function() { create_textbox("self_6"); }, talk_wait);
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