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
            if ((tilemap_get_at_pixel(_tm, _x, _y) & tile_index_mask) != 0) return true;
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