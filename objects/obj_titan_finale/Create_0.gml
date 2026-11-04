// the 6-person Titan battle's last attack (scr_start_titan_final makes it). like the last phase of the Flowery fight:
//   "intro": the battle UI goes. the camera pans slowly right, platforms rise out of the clouds off the tower's edge,
//            and the Titan sinks into the cloud sea. Ralsei: "Let's end this...". Susie holds up the Petal Feather: white.
//   "run":   Susie & Ralsei run right on their own across the platforms. Z / Up: jump (hold it: the feather slows
//            the fall), X: attack. the cloud sea stretches to the horizon and the Titan comes up out of it far away.
//            it throws orbs that land on the path ahead (a ! shows where: jump the low ones, stay down for the high
//            ones) and sends Titan Spawn (a ring closes in on them: X right as it closes). Queen's chair catches up
//            in the distance, Pink & Spamton on its arms, Jevil flying behind.
//   "final": the Titan sinks, the platform runs out, and it rises at the edge. its laser at Susie & Ralsei (they
//            defend); Queen, Pink, Spamton & Jevil appear behind them; the PRESS box comes up: mash Z. they go from
//            defending to parrying, push it back, and everyone goes for it: slow motion, white, black, the damage.
// it draws the whole run itself (over the room), so the room doesn't need to go anywhere.

// ---------------------------------------------------------------- tuning: the intro (rm_tower_top, room px)
intro_wait     = 40;       // frames after the battle UI goes
heal_hold      = 70;       // frames after it heals itself back to full, before it sinks
pan_time       = 360;      // the camera's slow pan right, to the end of the room
sink_dist      = 440;      // px the Titan sinks into the clouds...
sink_time      = 320;      // ...over this many frames
bank_top       = 330;      // the cloud bank it sinks into: its top (room px)...
bank_rise      = 160;      // ...which rises this far up into place...
bank_rise_time = 120;      // ...over this many frames
pillars        = 5;        // platforms rising out of the clouds off the tower's edge...
pillar_x0      = 1240;     // ...the first one's left edge (the floor ends at 1200)...
pillar_dx      = 150;      // ...each next one this much further right...
pillar_y0      = 110;      // ...its top here...
pillar_dy      = 45;       // ...each next one this much lower...
pillar_n       = 3;        // ...this many tiles wide
pillar_gap     = 45;       // frames between each one starting to rise...
pillar_rise    = 60;       // ...and each takes this long
feather_fist   = { x: 6.5, y: 1 };   // Susie's raised fist in spr_susie_right_hold's own px (rm_two's numbers)
feather_lift   = 14;       // px it rises above her fist...
feather_rise   = 24;       // ...over this many frames
feather_hold   = 80;       // frames it's up before the white
feather_sound  = snd_item;
white_in       = 30;       // frames to fade fully white...
white_hold     = 20;       // ...it holds...
white_out      = 45;       // ...and fades back out onto the run

// ---------------------------------------------------------------- tuning: the run (screen px)
run_speed      = 6;        // px a frame everything scrolls past
susie_sx       = 330;      // Susie's feet, across the screen...
ralsei_sx      = 250;      // ...and Ralsei's (he dodges on his own)
hw             = 12;       // their half-width
body_h         = 70;       // their height
grav           = 0.45;
jump_spd       = 9.6;
max_fall       = 10;
feather_fall   = 1.8;      // the most they fall a frame while you hold jump (the feather)
coyote_max     = 10;
buffer_max     = 10;
fall_dmg       = 10;       // ...for this much
invuln_max     = 90;
rescue_spd     = 17;       // fall down a gap (or into a wall) and the feather throws them back up this fast...
plat_w         = [6, 11];  // platform widths, tiles (40px)
plat_gap       = [50, 90]; // px between platforms
plat_step      = 40;       // px a platform can be higher or lower than the last
plat_y         = [270, 390];   // where their tops can be (where you stand)
plat_start_y   = 330;
stand_off      = 10;       // px down from a tile's top edge to where you stand on it
// the sky, the cloud sea and the horizon
horizon_y      = 150;
sky_top        = make_colour_rgb(0, 0, 0);
sky_low        = make_colour_rgb(34, 14, 52);
sea_base       = make_colour_rgb(40, 40, 48);   // under the puffs, so no black shows between the rows
cloud_rows     = 11;
cloud_far      = 0.16;     // a puff's size at the horizon (1 = right at the bottom of the screen)
cloud_scale    = 2.3;      // ...and at the bottom
cloud_parallax = 0.6;      // how fast the nearest row goes past, x the run's speed
cloud_light    = [0.3, 0.85];   // brightness at the horizon / the bottom (like the cloud sea up top)
// the Titan, far away (its star's place on screen; its sprite's px scaled)
titan_star     = { x: 172, y: 143 };   // the star on its face, in its sprite's own px
titan_anim     = 1 / 12;
titan_far_s    = 0.6;
titan_far      = { x: 610, y: 190 };   // its star, up
titan_far_z    = 0.32;     // which cloud rows are in front of it (the ones nearer than this)
titan_rise_at  = 90;       // frames into the run it starts coming up...
titan_rise_time = 200;     // ...taking this long...
titan_rise_dist = 220;     // ...from this far down
// what it throws
hazard_start   = 330;      // frames into the run the attacks start
run_len        = 3000;     // frames of attacks (50s), then the end
hazard_gap     = [150, 100];// frames between attacks: at the start / by the end
spawn_chance   = 0.25;     // how often it's a Titan Spawn (only one at a time)
pair_chance    = 0.15;     // how often a fish has another right behind it...
pair_gap       = 55;       // ...this many frames later
orb_time       = 70;       // frames a fish takes from its star to the path...
orb_land_sx    = 760;      // ...landing (at the soonest) where the path's at this x on screen
fish_scale     = 0.75;     // the Titan fish (head, 4 body pieces, tail), at this size...
fish_swim      = 2;        // px a frame it swims along the path at them (on top of the scrolling)
fish_hit_r     = 10;       // px around each piece that hurts
fish_gap       = 22;       // its pieces' spacing (sprite px), like obj_plat_titanfish
fish_tail_gap  = 20;
fish_wave      = 4;        // px each piece wiggles
fish_in        = 260;      // a low one is at least this far onto a platform when it gets to Susie (past where a jump over the gap comes down)...
fish_end       = 60;       // ...and this far short of its end (room to jump it, then the gap)
fish_in_high   = 270;      // a high one (any jump touches it) only in the middle of a long platform, away from the jumps
fish_end_high  = 140;
fish_space     = 360;      // px between any two (more than a jump)
ralsei_fish_lead = 40;     // px before a low fish reaches him that Ralsei jumps it
ralsei_edge_lead = 50;     // px before the end of his platform that he jumps the gap
fish_in_time   = 10;       // frames a new one takes to fade in at the star
orb_low        = 22;       // px above the path a low orb sits (jump it)...
orb_high       = 86;       // ...and a high one (stay down)
high_chance    = 0.15;
orb_dmg        = 20;
spawn_fly      = 80;       // frames a Titan Spawn takes to fly in from its star...
spawn_hover    = { x: 600, y: 230 };
ring_time      = 70;       // ...then the ring closes in on it over this long...
ring_r         = [110, 26];
ring_window    = 18;       // ...X within this many frames of it closing hits it
spawn_dmg      = 30;
spawn_lunge    = 16;       // frames it takes to fly into them if you miss
// Queen's chair, catching up in the distance (Pink & Spamton on its arms, Jevil flying behind)
queen_at       = 1500;     // frames into the run
queen_time     = 300;
queen_from     = { x: -120, y: 175, s: 0.3 };   // on screen; s: its scale (x2, like everyone)
queen_to       = { x: 470,  y: 215, s: 0.75 };
queen_z        = 0.45;
queen_bob      = 4;
arm_l          = { x: -20, y: 3 };    // Pink's feet, on the chair's left arm (chair sprite px from its origin)
arm_r          = { x: 21,  y: 3 };    // Spamton's, on the right
jevil_trail    = { x: -46, y: -22 };  // Jevil, flying behind it
// the end
final_sink     = 120;      // frames the far Titan takes to sink away
final_len      = 1400;     // px long, the last platform
edge_sx        = 690;      // where its edge stops, on screen
stop_decel     = 0.05;     // how hard they slow down
titan_near_s   = 1.5;
titan_near     = { x: 760, y: 190 };   // its star, once it's up at the edge
near_rise      = 160;      // frames it takes to rise...
near_rise_dist = 420;      // ...from this far down
laser_charge   = 50;
laser_w        = 30;
defend_gap     = 45;       // px Ralsei steps in to, behind Susie, when they put their defends up
retract        = 14;       // frames the laser takes to be knocked back into its star
laser_col_glow = make_colour_rgb(90, 40, 200);
laser_col      = make_colour_rgb(170, 110, 255);
laser_col_hot  = make_colour_rgb(230, 215, 255);
parry_col      = make_colour_rgb(255, 230, 140);
fire_col_glow  = make_colour_rgb(200, 40, 0);     // their fire beam into the shield...
fire_col       = make_colour_rgb(255, 120, 20);
fire_col_hot   = make_colour_rgb(255, 220, 90);
shield_col     = make_colour_rgb(255, 140, 30);   // ...and the shield: orange, curved toward the Titan
shield_hot     = make_colour_rgb(255, 235, 170);
shield_r       = 44;       // px: its curve's radius...
shield_span    = 140;      // ...how far round it goes (degrees)...
shield_th      = 10;       // ...and how thick its bright rim is
battle_s       = 1.6;      // battle sprites are bigger than the overworld ones: drawn at this instead of 2
defend_susie   = spr_susie_defend;
defend_ralsei  = spr_ralsei_defend;
parry_susie    = spr_susie_attack_ready;    // (placeholders until there are parry sprites)
parry_ralsei   = spr_ralsei_attack_ready;
allies_gap     = 40;       // frames between each of the four appearing behind them
// who appears behind them, bunched up right behind (screen x, px above the path), their pose, and how they go for
// it: Pink jumps with Susie & Ralsei; the others stay where they are and fire something at it (shot: a sprite, or -1
// for a ball of light in their colour)
allies = [
    { name: "Queen",   x: 240, up: 0,  spr: spr_queen_walk_right_unhappy, s: 2, anim: false, jump: false, atk: spr_queen_pie_throw,           shot: spr_pie,   col: make_colour_rgb(111, 209, 255), shield: true },
    { name: "Pink",    x: 200, up: 0,  spr: spr_mewmew_idle_corrupted,    s: 2, anim: true,  jump: true,  atk: spr_pink_throw_bomb_corrupted, shot: -1,        col: c_white,                        shield: false },
    { name: "Spamton", x: 165, up: 0,  spr: spr_spamton_right,            s: 2, anim: false, jump: false, atk: spr_spamton_armsout_right,     shot: spr_pipis, col: c_white,                        shield: false },
    { name: "Jevil",   x: 210, up: 80, spr: spr_jevil_dance,              s: 2, anim: true,  jump: false, atk: spr_jevil_dance,               shot: spr_spade, col: c_white,                        shield: false }
];
volley_frames  = 40;       // the ones who stay: how long their shots take to get to it
pink_takeoff    = 3;       // the frame of her throw she leaves the ground on (before it, she's crouching)
pink_bomb_frame = 12;      // ...and the one the bomb leaves her hand on
pink_bomb_at    = { x: 12, y: -136 };   // where the bomb is in her hand then (px from her feet, at 2x)
box_in         = 30;       // frames the PRESS box takes to come up
press_add      = 0.055;    // each Z fills it this much...
press_decay    = 0.0025;   // ...and it drains this much a frame
parry_at       = 0.05;     // they switch from defending to parrying once it's this full
jump_frames    = 70;       // their leap at it (before the slow motion)
slow_ts        = 0.12;     // the slow motion's speed...
slow_in        = 40;       // ...eased into over this long
white_up       = 150;      // frames the screen takes to glow fully white...
white_stay     = 180;      // ...holds...
black_in       = 60;       // ...then fades to black
dmg_gap        = 28;       // frames between each damage number...
dmg_hold       = 150;      // ...and how long they stay up after the last
dmg_weights    = { Susie: 0.24, Ralsei: 0.18, Queen: 0.16, Pink: 0.16, Jevil: 0.15, Spamton: 0.11 };
dmg_cols       = { Susie: make_colour_rgb(234, 121, 200), Ralsei: make_colour_rgb(77, 204, 142), Queen: make_colour_rgb(111, 209, 255),
                   Pink: make_colour_rgb(255, 138, 144),  Jevil: make_colour_rgb(150, 150, 255), Spamton: make_colour_rgb(251, 242, 54) };

// ---------------------------------------------------------------- refs + state
scene = instance_find(obj_tower_top_scene, 0);
vw    = camera_get_view_width(view_camera[0]);
vh    = camera_get_view_height(view_camera[0]);
depth = 20;   // the intro: in front of the Titan (25), behind the floor (0) and everyone. the run: in front of everything
t     = 0;
phase = "intro";
white = { a: 0, to: 0, spd: 0 };
black = 0;
shake = { amt: 0, t: 0, x: 0, y: 0 };

// HP: the boxes' (Susie & Ralsei), and what the Titan's got left (the numbers at the end add up to it)
hp     = { Susie: 290, Ralsei: 210 };
max_hp = { Susie: 290, Ralsei: 210 };
with (obj_battle_ui_box) if (char_name == "Susie" || char_name == "Ralsei") { other.hp[$ char_name] = max(1, hp); other.max_hp[$ char_name] = max_hp; }
titan_hp  = 6000;
titan_max = 6000;
with (obj_battle_target) if (kind == "titan") { other.titan_hp = max(1, hp); other.titan_max = max_hp; }

// the intro
pillar_k = array_create(pillars, 0);
pillar_t = -1;
bank_k   = 0;
sink     = undefined;   // { t, y0 }
feather  = { on: false, t: 0 };

// the run
dist     = 0;
spd      = run_speed;
run_t    = 0;
segs     = [ { x0: -400, x1: 1400, y: plat_start_y } ];
final_plan = false;
final_made = false;
final_edge = 0;
make_member = function(_who, _sx)
{
    return { who: _who, sx: _sx, y: plat_start_y, vy: 0, grounded: true, coyote: 0, jbuf: 0, glide: false,
             invuln: 0, atk: undefined, cool: 0, pose: "run", fx: 0 };
}
susie  = make_member("Susie", susie_sx);
ralsei = make_member("Ralsei", ralsei_sx);
orbs     = [];          // { wx, y, k, sx0, sy0, high, landed, done }
spawn    = undefined;   // { who, st, t, x, y, s, dead }
shots    = [];          // { x, y, tx, ty, spr, t, time, kill }
pops     = [];          // { x, y, t, spr } little bursts
next_hazard = hazard_start;
titan_far_k = 0;        // 0 = under the clouds, 1 = up
queen_k     = -1;       // -1: not yet

// the end
fin      = { st: "", t: 0 };
titan_near_k = 0;
press_k  = 0;
press_on = false;
box_k    = 0;
ally_k   = array_create(array_length(allies), 0);
ts       = 1;           // time's speed (the slow motion)
leap     = [];          // everyone going for it: { name, spr, s, x0, y0, x1, y1, k, h, delay, stay }
volley   = [];          // the shots from the ones who stay: { spr, col, x0, y0, x1, y1, k, delay, rot }
shield_pos = { x: 0, y: 0, dir: 0 };   // (where the shield last was: it fades out there once they've won)
dmg_list = [];          // { name, amount, x, y, t }
dmg_t    = 0;

// ---------------------------------------------------------------- helpers
approach = function(_v, _to, _step) { return (_v < _to) ? min(_to, _v + _step) : max(_to, _v - _step); }
spd_of   = function(_spr) { return sprite_get_speed(_spr) / game_get_speed(gamespeed_fps); }
do_shake = function(_amt, _time) { shake.amt = max(shake.amt, _amt); shake.t = max(shake.t, _time); }
view_x = function() { return camera_get_view_x(view_camera[0]) + shake.x; }
view_y = function() { return camera_get_view_y(view_camera[0]) + shake.y; }
/// _spr's frame _img with the bottom-middle of its canvas on (_x, _y) (whatever its origin is), at scale _s
draw_feet = function(_spr, _img, _x, _y, _s, _a = 1)
{
    draw_sprite_ext(_spr, _img, _x + (sprite_get_xoffset(_spr) - sprite_get_width(_spr) / 2) * _s,
                    _y + (sprite_get_yoffset(_spr) - sprite_get_height(_spr)) * _s, _s, _s, 0, c_white, _a);
}

/// a tile of the castle's tileset with its top-left at (_x, _y)
tile = function(_ti, _x, _y)
{
    draw_sprite_part(spr_ralsei_castle_tiles, 0, 2 + (_ti mod 6) * 44, 2 + (_ti div 6) * 44, 40, 40, _x, _y);
}
/// a platform _n tiles wide, its top-left at (_x, _y), going down to _bottom
draw_pillar = function(_x, _y, _n, _bottom)
{
    for (var c = 0; c < _n; c++)
    {
        var _top = (c == 0) ? 17 : ((c == _n - 1) ? 19 : 18);
        var _mid = (c == 0) ? 21 : ((c == _n - 1) ? 23 : 22);
        tile(_top, _x + c * 40, _y);
        for (var _yy = _y + 40; _yy < _bottom; _yy += 40) tile(_mid, _x + c * 40, _yy);
    }
}
/// the Titan, idling, its star at (_sx, _sy), at scale _s
titan_layers = [spr_titan_0_backwing, spr_titan_1_backwing, spr_titan_2_backwing, spr_titan_3_backwing, spr_cover_wings_defense_layer_4,
                spr_titan_star_dissapear, spr_titan_5_backwing, spr_titan_6_backwing, spr_titan_7_backwing];
draw_titan = function(_sx, _sy, _s, _col = c_white, _a = 1)
{
    var _tlx = _sx - titan_star.x * _s, _tly = _sy - titan_star.y * _s;
    for (var i = 0; i < array_length(titan_layers); i++)
    {
        var _spr = titan_layers[i];
        draw_sprite_ext(_spr, (_spr == spr_titan_star_dissapear) ? 0 : t * titan_anim, _tlx + sprite_get_xoffset(_spr) * _s,
            _tly + sprite_get_yoffset(_spr) * _s, _s, _s, 0, _col, _a);
    }
}
/// a puff of the cloud sea
puff = function(_x, _y, _s, _img, _light)
{
    draw_sprite_ext(spr_rising_cloudx2_outline, _img, _x, _y, _s, _s, 0, merge_colour(c_black, c_white, clamp(_light, 0, 1)), 1);
}
/// the cloud sea's rows, from the horizon down, the ones whose depth (0 far - 1 near) is in [_z0, _z1)
row_z = function(_i) { var _u = _i / (cloud_rows - 1); return lerp(cloud_far, 1, _u * _u); }
row_y = function(_z) { return lerp(horizon_y, vh + 10, (_z - cloud_far) / (1 - cloud_far)); }
draw_rows = function(_z0, _z1, _ox, _oy)
{
    for (var i = 0; i < cloud_rows; i++)
    {
        var _z = row_z(i);
        if (_z < _z0 || _z >= _z1) continue;
        var _s   = cloud_scale * _z;
        var _gap = 44 * _s;
        var _y   = row_y(_z);
        var _off = (dist * _z * cloud_parallax + i * 37) mod _gap;
        var _l   = lerp(cloud_light[0], cloud_light[1], (_y - horizon_y) / (vh - horizon_y));
        for (var _x = -_gap - _off; _x < vw + _gap; _x += _gap)
        {
            var _k = floor((_x + _off) / _gap) + i * 7;   // (which puff this is, so each keeps its frame and bob)
            puff(_ox + _x, _oy + _y + sin(t / 30 + _k) * 2 * _z, _s, abs(_k) mod 3, _l + ((abs(_k) mod 5) - 2) * 0.02);
        }
    }
}

/// the laser (obj_ralsei_rage's): a soft band, _col down the middle fading out to its edges (under bm_add)
soft_strip = function(_x1, _y1, _x2, _y2, _w, _col, _a)
{
    var _len = point_distance(_x1, _y1, _x2, _y2);
    if (_len < 1 || _a <= 0) return;
    var _d  = point_direction(_x1, _y1, _x2, _y2);
    var _nx = lengthdir_x(1, _d + 90), _ny = lengthdir_y(1, _d + 90);
    for (var _side = -1; _side <= 1; _side += 2)
    {
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_colour(_x1, _y1, _col, _a);
        draw_vertex_colour(_x1 + _nx * _w * 0.5 * _side, _y1 + _ny * _w * 0.5 * _side, c_black, _a);
        draw_vertex_colour(_x2, _y2, _col, _a);
        draw_vertex_colour(_x2 + _nx * _w * 0.5 * _side, _y2 + _ny * _w * 0.5 * _side, c_black, _a);
        draw_primitive_end();
    }
}
draw_beam = function(_x1, _y1, _x2, _y2, _w, _a, _glow, _mid, _hot)
{
    if (_a <= 0) return;
    var _fl = 1 + 0.08 * sin(t * 1.7) + random_range(-0.04, 0.04);
    gpu_set_blendmode(bm_add);
    soft_strip(_x1, _y1, _x2, _y2, _w * 4 * _fl, _glow, 0.6 * _a);
    soft_strip(_x1, _y1, _x2, _y2, _w * 2 * _fl, _mid,  0.9 * _a);
    soft_strip(_x1, _y1, _x2, _y2, _w * _fl,     _hot,  _a);
    soft_strip(_x1, _y1, _x2, _y2, _w * 0.5,     c_white, _a);
    soft_strip(_x1, _y1, _x2, _y2, _w * 0.5,     c_white, _a);
    draw_set_alpha(_a);
    draw_circle_colour(_x1, _y1, _w * 2.4 * _fl, c_white, c_black, false);
    draw_circle_colour(_x2, _y2, _w * 2.0 * _fl, _hot, c_black, false);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

/// the party's shield: an orange curve of light around (_x, _y), facing _dir, glowing at its rim and fading into it
draw_shield = function(_x, _y, _dir, _a)
{
    if (_a <= 0) return;
    var _r = shield_r * (1 + 0.04 * sin(t * 0.5));
    var _n = 18;
    gpu_set_blendmode(bm_add);
    // the dome: faint orange, brightest at the rim
    draw_primitive_begin(pr_trianglestrip);
    for (var i = 0; i <= _n; i++)
    {
        var _ang = _dir - shield_span / 2 + shield_span * i / _n;
        var _e   = 1 - abs(i / _n - 0.5) * 2;   // (fades toward its ends)
        draw_vertex_colour(_x + lengthdir_x(_r, _ang), _y + lengthdir_y(_r, _ang), merge_colour(c_black, shield_col, _e), 0.5 * _a);
        draw_vertex_colour(_x + lengthdir_x(_r * 0.25, _ang), _y + lengthdir_y(_r * 0.25, _ang), c_black, _a);
    }
    draw_primitive_end();
    // the rim: a glow either side of a white-hot line
    for (var _side = -1; _side <= 1; _side += 2)
    {
        draw_primitive_begin(pr_trianglestrip);
        for (var i = 0; i <= _n; i++)
        {
            var _ang = _dir - shield_span / 2 + shield_span * i / _n;
            var _e   = 1 - abs(i / _n - 0.5) * 2;
            draw_vertex_colour(_x + lengthdir_x(_r, _ang), _y + lengthdir_y(_r, _ang), merge_colour(c_black, shield_hot, _e), _a);
            draw_vertex_colour(_x + lengthdir_x(_r + _side * shield_th, _ang), _y + lengthdir_y(_r + _side * shield_th, _ang), c_black, _a);
        }
        draw_primitive_end();
    }
    // sparks where the laser hits it
    var _hx = _x + lengthdir_x(_r, _dir), _hy = _y + lengthdir_y(_r, _dir);
    draw_set_alpha(_a);
    for (var i = 0; i < 4; i++)
        draw_circle_colour(_hx + random_range(-10, 10), _hy + random_range(-14, 14), random_range(2, 5), c_white, shield_col, false);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

// --- the run's platforms ---
/// where you'd stand at run-x _wx (-1: nothing there). _pad: how far off a platform's edge you still stand on it
ground_at = function(_wx, _pad = 0)
{
    for (var i = 0; i < array_length(segs); i++)
    {
        var _s = segs[i];
        if (_wx >= _s.x0 - _pad && _wx <= _s.x1 + _pad) return _s.y;
    }
    return -1;
}
/// more platforms out ahead (and none left behind)
gen = function()
{
    while (true)
    {
        var _last = segs[array_length(segs) - 1];
        if (_last.x1 > dist + vw + 400 || final_made) break;
        var _gap = irandom_range(plat_gap[0], plat_gap[1]);
        if (final_plan)
        {
            // the last one: long, and where the Titan comes up at its edge
            array_push(segs, { x0: _last.x1 + _gap, x1: _last.x1 + _gap + final_len, y: _last.y });
            final_edge = _last.x1 + _gap + final_len;
            final_made = true;
            break;
        }
        var _n = irandom_range(plat_w[0], plat_w[1]);
        var _y = clamp(_last.y + choose(-plat_step, 0, plat_step, plat_step), plat_y[0], plat_y[1]);
        array_push(segs, { x0: _last.x1 + _gap, x1: _last.x1 + _gap + _n * 40, y: _y });
    }
    while (array_length(segs) > 1 && segs[0].x1 < dist - 200) array_delete(segs, 0, 1);
}

// --- Susie & Ralsei ---
hurt = function(_m, _dmg)
{
    if (_m.invuln > 0) return;
    hp[$ _m.who] = max(1, hp[$ _m.who] - _dmg);   // (it can't end here: they always get to the end)
    _m.invuln = invuln_max;
    audio_play_sound(snd_hurt, 1, false);
    do_shake(4, 12);
    array_push(pops, { x: _m.sx, y: _m.y - body_h / 2, t: 0, spr: spr_titan_shockwave_bullet_explosion, s: 0.12, txt: string(_dmg), col: c_white });
}
/// one frame of running / jumping for _m, with this frame's inputs (_jp: jump pressed, _jh: jump held)
move_member = function(_m, _jp, _jh)
{
    var _wx = dist + _m.sx;
    if (_m.invuln > 0) _m.invuln--;
    if (_m.cool > 0) _m.cool--;
    _m.coyote = _m.grounded ? coyote_max : max(0, _m.coyote - 1);
    _m.jbuf   = _jp ? buffer_max : max(0, _m.jbuf - 1);
    if (_m.jbuf > 0 && _m.coyote > 0) { _m.vy = -jump_spd; _m.grounded = false; _m.coyote = 0; _m.jbuf = 0; }
    _m.glide = _jh && _m.vy > 0;

    if (!_m.grounded) _m.vy = min(_m.vy + grav, _m.glide ? feather_fall : max_fall);
    var _g  = ground_at(_wx, hw);
    var _ny = _m.y + _m.vy;
    if (_g != -1 && _m.vy >= 0 && _m.y <= _g + 2 && _ny >= _g) { _m.y = _g; _m.vy = 0; _m.grounded = true; }
    else
    {
        _m.y = _ny;
        if (_m.grounded && (_g == -1 || abs(_g - _m.y) > 2)) _m.grounded = false;
        // ran into a platform's side, or fell: the feather throws them back up
        if ((_g != -1 && _m.y > _g + 6 && !_m.grounded && _m.vy >= 0) || _m.y > vh + 40)
        {
            hurt(_m, fall_dmg);
            _m.vy = -rescue_spd;
            audio_play_sound(snd_sparklegem, 1, false);
        }
    }
}
/// X: _m attacks (at the Titan Spawn, if there is one)
attack = function(_m)
{
    if (_m.atk != undefined || _m.cool > 0) return;
    var _hit = false;
    if (spawn != undefined && spawn.st == "ring" && spawn.who == _m.who && abs(spawn.t - ring_time) <= ring_window) _hit = true;
    _m.atk = { t: 0, fired: false, hit: _hit };
    _m.cool = 25;
}
atk_sprite = function(_m) { return (_m.who == "Susie") ? spr_susie_rudebuster : spr_plat_ralsei_fireball; }
atk_fire   = function(_m) { return (_m.who == "Susie") ? 7 : 3; }
atk_from   = function(_m) { return (_m.who == "Susie") ? { x: 38, y: -41 } : { x: 12, y: -21 }; }

// --- the Titan's attacks ---
/// where its star is on the screen right now (far away)
far_star = function()
{
    var _k = titan_far_k;
    return { x: titan_far.x, y: titan_far.y + titan_rise_dist * (1 - _k * _k * (3 - 2 * _k)) };
}
throw_orb = function()
{
    var _st   = far_star();
    var _r    = run_speed, _s = fish_swim;
    var _d    = dist + _r * orb_time + susie_sx;          // where Susie is when it lands
    var _want = dist + orb_land_sx + _r * orb_time;       // (the soonest bit of path it can get to in time)
    var _meet = (_r * _want + _s * _d) / (_r + _s);       // ...and where that one would have swum to by the time she gets to it
    // a spot it can be dodged from (where it is when she gets to it): far enough onto a platform and short of its end
    var _place = function(_wx, _in, _end)
    {
        for (var i = 0; i < array_length(segs); i++)
        {
            var _sg = segs[i];
            if (_sg.x1 - _end < _wx) continue;
            var _x = max(_wx, _sg.x0 + _in);
            if (_x <= _sg.x1 - _end) return { x: _x, y: _sg.y };
        }
        return undefined;
    };
    var _high = random(1) < high_chance;
    var _spot = _high ? _place(_meet, fish_in_high, fish_end_high) : undefined;
    if (_spot == undefined) { _high = false; _spot = _place(_meet, fish_in, fish_end); }
    if (_spot == undefined) return;
    var _land = (_spot.x * (_r + _s) - _s * _d) / _r;     // where it lands, to have swum to the spot when she gets there
    var _c    = _land + _s * (t + orb_time);              // (its place with the swimming taken out: they all swim the same, so this is how far apart they stay)
    for (var i = 0; i < array_length(orbs); i++) if (abs(orbs[i].c - _c) < fish_space) return;   // (too close to another)
    array_push(orbs, { wx: _land, c: _c, y: _spot.y - (_high ? orb_high : orb_low), k: 0, sx0: _st.x, sy0: _st.y, high: _high, landed: false, done: false });
    audio_play_sound(snd_spawn_attack, 1, false, 0.6);
}

/// Ralsei jumps by himself: over a low fish that's about to get to him, and off the end of his platform
ralsei_jump = function()
{
    var _m = ralsei;
    if (!_m.grounded) return false;
    var _wx  = dist + _m.sx;
    var _len = (4 * fish_gap + fish_tail_gap) * fish_scale;
    var _rr  = fish_hit_r * fish_scale;
    // a low fish coming at him
    for (var i = 0; i < array_length(orbs); i++)
    {
        var _o = orbs[i];
        if (!_o.landed || _o.done || _o.high) continue;
        if (abs(_o.y + orb_low - _m.y) > 20) continue;   // (not on his platform)
        var _hx = _o.wx - dist;
        if (_hx - _rr - (_m.sx + hw) <= ralsei_fish_lead && _hx + _len + _rr > _m.sx - hw) return true;
    }
    // the end of the platform he's on (not the last one)
    for (var i = 0; i < array_length(segs); i++)
    {
        var _sg = segs[i];
        if (_wx >= _sg.x0 && _wx <= _sg.x1) return (_sg.x1 - _wx <= ralsei_edge_lead) && (i < array_length(segs) - 1);
    }
    return false;
}
/// piece _k of a fish (0 = head, 1-4 = body, 5 = tail) whose head's at (_hx, _hy), going _ang, at scale _s
fish_piece = function(_k, _hx, _hy, _ang, _s, _ph)
{
    var _back = ((_k <= 4) ? _k * fish_gap : 4 * fish_gap + fish_tail_gap) * _s;
    var _wig  = sin(_ph - _k * 0.7) * fish_wave * _s;
    return { x: _hx - lengthdir_x(_back, _ang) + lengthdir_x(_wig, _ang + 90),
             y: _hy - lengthdir_y(_back, _ang) + lengthdir_y(_wig, _ang + 90) };
}
/// a whole fish (its sprites face right as drawn: anything going leftish is flipped instead of turned upside down)
draw_fish = function(_hx, _hy, _ang, _s, _ph, _al = 1)
{
    var _left = (lengthdir_x(1, _ang) < 0);
    var _xs   = _left ? -_s : _s;
    var _a    = _left ? _ang - 180 : _ang;
    var _f    = t / 6;
    var _p    = fish_piece(5, _hx, _hy, _ang, _s, _ph);
    draw_sprite_ext(spr_titanfish_tail, _f, _p.x, _p.y, _xs, _s, _a, c_white, _al);
    for (var k = 4; k >= 1; k--)
    {
        _p = fish_piece(k, _hx, _hy, _ang, _s, _ph);
        draw_sprite_ext(spr_titanfish_body, _f + k, _p.x, _p.y, _xs, _s, _a, c_white, _al);
    }
    draw_sprite_ext(spr_titanfish_head, _f, _hx, _hy, _xs, _s, _a, c_white, _al);
}
send_spawn = function()
{
    var _st = far_star();
    spawn = { who: choose("Susie", "Ralsei"), st: "fly", t: 0, x: _st.x, y: _st.y, x0: _st.x, y0: _st.y, s: 0.2, dead: 0 };
    audio_play_sound(snd_titanspawn, 1, false, 0.7);
}

// ---------------------------------------------------------------- the intro, step by step
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

add(function()
{
    // everyone out of their readies, facing the edge
    scene.pose_flip(obj_susie,   spr_susie_walk_right_neutral, 2);
    scene.pose_flip(obj_ralsei,  scene.ralsei_right, 2);
    scene.pose_flip(obj_queen,   spr_queen_walk_right_unhappy, 2);
    scene.pose_flip(obj_mewmew,  spr_mewmew_idle_corrupted, 2);
    scene.pose_flip(obj_spamton, spr_spamton_right, 2);
    with (obj_susie)   image_speed = 0;
    with (obj_ralsei)  image_speed = 0;
    with (obj_queen)   image_speed = 0;
    with (obj_spamton) image_speed = 0;
}, undefined, intro_wait);
add(function()
{
    // it heals itself all the way back up first
    var _amt = max(0, titan_max - titan_hp);
    titan_hp = titan_max;
    if (instance_exists(obj_ralsei_rage)) { with (obj_ralsei_rage) if (_amt > 0) titan_heal(_amt); }
    else audio_play_sound(snd_heal, 1, false, 1, 0, 0.6);
}, undefined, heal_hold);
add(function()
{
    // the slow pan right. the platforms come up out of the clouds, the clouds rise, it sinks
    scene.pan_cam(room_width - vw, pan_time);
    pillar_t = 0;
    var _ti = instance_find(obj_titan_reveal, 0);
    sink = { t: 0, y0: (_ti != noone) ? _ti.y : 0 };
    audio_play_sound(snd_titan_wingshut, 1, false);
    scr_camera_shake(2, 60);
}, function() { return !scene.cam_pan.on && sink.t >= sink_time && pillar_k[pillars - 1] >= 1; }, 30);
add(function()
{
    with (obj_titan_reveal) visible = false;   // (under the clouds now)
    scene.pose_flip(obj_ralsei, scene.ralsei_down, 2);
    with (obj_ralsei) image_speed = 0;
    create_textbox("self_24");                  // Ralsei: "Let's end this..."
}, function() { return !instance_exists(obj_textbox); }, 10);
add(function()
{
    // the Petal Feather
    scene.pose_flip(obj_susie, spr_susie_right_hold, 2);
    feather = { on: true, t: 0 };
    audio_play_sound(feather_sound, 1, false);
}, undefined, feather_hold);
add(function()
{
    white.to = 1; white.spd = 1 / white_in;
    audio_play_sound(snd_sparklegem, 1, false);
}, function() { return white.a >= 1; }, white_hold);
add(function()
{
    // the run
    feather.on = false;
    depth = -9000;
    phase = "run";
    white.to = 0; white.spd = 1 / white_out;
    with (obj_textbox) instance_destroy();
});