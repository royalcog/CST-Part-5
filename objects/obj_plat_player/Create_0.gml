// one of the two climbers (Susie or Ralsei). obj_plat_controller makes both and decides who you're controlling:
// the one you control runs on the physics below, the other one follows your trail (the controller moves it).
// x/y = their feet (the plat sprites' origins are on the feet)
image_xscale = 2;
image_yscale = 2;
depth = -100;

// --- tuning ---
hw        = 12;      // hitbox half-width, px
hh        = 70;      // hitbox height, px (from the feet up)
walk_spd  = 3.5;     // px per frame
accel     = 0.7;     // how fast they get up to speed...
decel     = 0.9;     // ...and stop
grav      = 0.45;
jump_spd  = 9.6;     // ~100px jump
jump_cut  = 0.5;     // let go of jump early and the rise is cut to this much
max_fall  = 10;
coyote_max = 6;      // frames you can still jump after walking off a ledge
buffer_max = 6;      // frames a jump press is remembered before landing

// --- attacking (X, on the ground only): aims at the closest Titan Spawn ---
attack_key       = ord("X");
attack_cool_max  = 30;                      // frames before you can attack again (~0.5s)
buster_sprite    = spr_susie_rudebuster;    // Susie (her battle sprite, scaled down)
buster_scale     = 2;
buster_anim      = 2;                       // x its normal speed
buster_fire      = 7;                       // frame the Rude Buster leaves her swing
buster_from      = { x: 38, y: -41 };       // where it leaves from, in the sprite's px from her origin
buster_sound     = snd_boost;
fire_sprite      = spr_plat_ralsei_fireball;   // Ralsei
fire_scale       = 2;
fire_anim        = 2;
fire_fire        = 3;
fire_from        = { x: 12, y: -21 };
fire_sound       = snd_smallswing;

// --- getting hurt ---
invuln_max = 60;     // frames you can't be hurt again (you blink)
hurt_lock  = 16;     // frames you've no control while you're knocked back
knock_x    = 5;
knock_y    = 5;
hurt_sound = snd_hurt;

// --- state ---
who      = "";
leader   = false;
face     = 1;        // 1 = right, -1 = left
vx = 0; vy = 0;
xr = 0; yr = 0;      // sub-pixel leftovers
grounded = false;
coyote   = 0;
jbuf     = 0;
spr_idle = noone;
spr_run  = noone;
spr_jump = noone;
attacking   = false;
atk_t       = 0;
atk_fired   = false;
attack_cool = 0;
invuln      = 0;
hurt_t      = 0;
face_hold   = 0;     // > 0: the follower keeps facing the way it was turned (for dialogue)
atk_target  = noone;  // who this attack's aimed at (noone = whoever's closest)

/// sets up the sprites for "susie" or "ralsei"
set_who = function(_who)
{
    who = _who;
    if (_who == "susie")
    {
        spr_idle = spr_plat_susie_unhappy;
        spr_run  = spr_plat_susie_run;
        spr_jump = spr_plat_susie_jump;
    }
    else
    {
        spr_idle = spr_plat_ralsei_idle;
        spr_run  = spr_plat_ralsei_run;
        spr_jump = spr_plat_ralsei_jump;
    }
    sprite_index = spr_idle;
    image_index  = 0;
    image_speed  = 1;
}

/// is the body (feet at _x,_y) overlapping a solid?
// collision comes from the tile layers (any tile = solid), plus any obj_plat_solid / obj_plat_ledge still placed
tm_solid = layer_exists("Tiles_Solid") ? layer_tilemap_get_id(layer_get_id("Tiles_Solid")) : -1;
tm_ledge = layer_exists("Tiles_Ledge") ? layer_tilemap_get_id(layer_get_id("Tiles_Ledge")) : -1;

/// any tile on _tm inside the rectangle?
tile_in_rect = function(_tm, _l, _t, _r, _b)
{
    if (_tm == -1) return false;
    var _tw = tilemap_get_tile_width(_tm), _th = tilemap_get_tile_height(_tm);
    for (var _y = _t; ; _y = min(_y + _th, _b))
    {
        for (var _x = _l; ; _x = min(_x + _tw, _r))
        {
            if ((tilemap_get_at_pixel(_tm, scr_plat_wrap(_x), _y) & tile_index_mask) != 0) return true;
            if (_x >= _r) break;
        }
        if (_y >= _b) break;
    }
    return false;
}

/// is the body (feet at _x,_y) overlapping a solid?
solid_at = function(_x, _y)
{
    var _l = _x - hw, _t = _y - hh, _r = _x + hw - 1, _b = _y - 1;
    return tile_in_rect(tm_solid, _l, _t, _r, _b)
        || collision_rectangle(_l, _t, _r, _b, obj_plat_solid, false, true) != noone;
}

/// is there a ledge whose top row is exactly at _y, under feet at _x?
ledge_under = function(_x, _y)
{
    var _l = _x - hw, _r = _x + hw - 1;

    // a ledge tile whose top edge is this row
    if (tm_ledge != -1)
    {
        var _th = tilemap_get_tile_height(tm_ledge);
        var _oy = tilemap_get_y(tm_ledge);
        if (((_y - _oy) mod _th) == 0 && tile_in_rect(tm_ledge, _l, _y, _r, _y)) return true;
    }

    var _hit = false;
    with (obj_plat_ledge)
    {
        if (bbox_top == _y && bbox_right >= _l && bbox_left <= _r) { _hit = true; break; }
    }
    return _hit;
}

on_ground = function()
{
    return solid_at(x, y + 1) || ledge_under(x, y);
}

/// picks the sprite for what they're doing. used by the follower too
animate = function(_moving, _grounded, _vy)
{
    image_xscale = 2 * face;
    if (!_grounded)
    {
        sprite_index = spr_jump;
        image_speed  = 0;
        var _n = sprite_get_number(spr_jump);
        image_index = (_vy < -2) ? 0 : ((_vy <= 2) ? min(1, _n - 1) : _n - 1);   // rising, at the top, falling
    }
    else if (_moving)
    {
        if (sprite_index != spr_run) { sprite_index = spr_run; image_index = 0; }
        image_speed = 1;
    }
    else
    {
        if (sprite_index != spr_idle) { sprite_index = spr_idle; image_index = 0; }
        image_speed = 1;
    }
}

/// X: Susie's Rude Buster or Ralsei's fireball, at _target (or the closest Titan Spawn)
start_attack = function(_target = noone)
{
    if (attacking || attack_cool > 0 || !grounded || hurt_t > 0) return;
    attacking = true;
    atk_t     = 0;
    atk_fired = false;
    vx = 0;
    atk_target = (_target != noone && instance_exists(_target)) ? _target : noone;
    var _t = (atk_target != noone) ? atk_target : instance_nearest(x, y - hh / 2, obj_plat_titanspawn);
    if (_t != noone && !_t.dying) face = (scr_plat_wrap_dx(x, _t.x) >= 0) ? 1 : -1;
    sprite_index = (who == "susie") ? buster_sprite : fire_sprite;
    image_speed  = 0;
    image_index  = 0;
    var _len = sprite_get_number(sprite_index) / (sprite_get_speed(sprite_index) * ((who == "susie") ? buster_anim : fire_anim)) * game_get_speed(gamespeed_fps);
    attack_cool = max(attack_cool_max, ceil(_len));
}

/// runs the attack animation; true while it's still going
attack_step = function()
{
    var _spr   = (who == "susie") ? buster_sprite : fire_sprite;
    var _scale = (who == "susie") ? buster_scale  : fire_scale;
    var _mult  = (who == "susie") ? buster_anim   : fire_anim;
    var _ff    = (who == "susie") ? buster_fire   : fire_fire;
    var _from  = (who == "susie") ? buster_from   : fire_from;

    atk_t++;
    var _f = atk_t * sprite_get_speed(_spr) * _mult / game_get_speed(gamespeed_fps);
    sprite_index = _spr;
    image_index  = min(floor(_f), sprite_get_number(_spr) - 1);
    image_xscale = _scale * face;
    image_yscale = _scale;

    if (!atk_fired && _f >= _ff)
    {
        atk_fired = true;
        var _sx = x + _from.x * _scale * face;
        var _sy = y + _from.y * _scale;
        var _t  = (instance_exists(atk_target) && !atk_target.dying) ? atk_target : instance_nearest(_sx, _sy, obj_plat_titanspawn);
        if (_t != noone && _t.dying) _t = noone;
        var _d  = (_t != noone) ? point_direction(0, 0, scr_plat_wrap_dx(_sx, _t.x), _t.y - _sy) : ((face > 0) ? 0 : 180);
        var _shot = instance_create_depth(_sx, _sy, -160, obj_plat_shot);
        _shot.setup((who == "susie") ? "buster" : "fire", _t, _d);
        var _snd = (who == "susie") ? buster_sound : fire_sound;
        if (_snd != noone) audio_play_sound(_snd, 1, false);
    }

    if (_f >= sprite_get_number(_spr))
    {
        attacking = false;
        image_yscale = 2;
        return false;
    }
    return true;
}

/// a Titan Spawn touched them (from _fx). the one you control gets knocked back
take_hit = function(_fx, _amount)
{
    if (invuln > 0) return;
    invuln = invuln_max;
    scr_show_damage(id, _amount);
    if (hurt_sound != noone) audio_play_sound(hurt_sound, 1, false);
    if (leader)
    {
        attacking = false;
        image_yscale = 2;
        hurt_t = hurt_lock;
        var _away = (scr_plat_wrap_dx(_fx, x) >= 0) ? 1 : -1;
        vx = _away * knock_x;
        vy = -knock_y;
        grounded = false;
    }
}