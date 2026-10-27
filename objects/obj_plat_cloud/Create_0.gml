// the dark cloud, ported from Deltarune's obj_cloud_controller_new / obj_cloud_render_new.
// two modes (set by whoever makes it, right after creating it):
//  "rise" - the tower climb (obj_plat_controller makes it). two rings of puffs around the tower, slowly spinning,
//           sitting on a black mass at the bottom of the screen. it shows up once you're halfway up rm_tower, then
//           creeps up after you (faster the further ahead you get), carries on into rm_tower2, and hurts if it catches you.
//           drawn in obj_plat_controller's Post Draw, around the tower: the back half behind it, the front half over everything.
//  "sea"  - rm_tower_top (its creation code makes it). puffs fill every empty cell around the floor tiles,
//           like the top of the tower's sticking up out of the clouds. the ones touching the floor overlap its edges.
mode       = "rise";
entry_kind = "start";    // "rise": how you got into this room ("fall" = dropped in from the room above)
front      = false;      // "sea": the edge puffs (made automatically)
sea_layer  = "Tiles_1";  // "sea": the floor's tile layer

// --- the sprites (named directly: "remove unused assets" is on, so looking them up by name finds nothing) ---
spr_puff    = spr_rising_cloudx2_outline;   // the puffs (3 frames)
spr_puff_ol = spr_rising_cloudx2;           // the extra layer under them, when outline = true
spr_bg      = spr_rising_bg;                // the black mass they sit on (2 frames)
outline     = false;

// --- tuning: the rings (Deltarune: 10 puffs at 175, then 18 at 300, on a 640-wide screen) ---
ring_count  = [10, 18];
ring_dr     = [175, 300];  // Deltarune's distances (the colour/height maths use these)
ring_r      = [270, 440];  // how far out they go across our screen, px (the tower's about 248 px out)
puff_scale  = 2;
spin_speed  = 0.2;         // degrees per frame
tilt        = 1.2;         // how much the rings tip into an oval when the cloud's above/below the middle of the screen
bob_x       = 4;           // px
bob_y       = 4;

// --- tuning: rising ---
arrive_gap   = 330;        // px below the one you're controlling that it starts at (just under the screen), then rises in
min_gap      = 140;        // px below them it's put when you come up into the next room
min_speed    = -0.3;       // px per frame when it's right under you (slow, so there's time to platform)
max_speed    = -0.9;       // px per frame once you're 300px+ above it
catchup      = -6;         // px per frame when you're more than 450px above it (keeps it from being left behind)
hurt_on      = true;       // false: it just follows along and never hurts
hurt_dist    = 34;         // it hurts once their feet are this far down into it (its top line's the very tips of the puffs)
hurt_depth   = 140;        // further down than this and they've fallen right through it: no hurting, it sinks to stay under them
damage_min   = 20;
damage_max   = 30;
push_back    = 10;         // after it hurts you, it sinks back down (this fast at first, slowing by 0.2 a frame)

// --- tuning: the sea ---
sea_near_light = 0.85;     // brightness of the puffs at the bottom of the room...
sea_far_light  = 0.3;      // ...and at the top (further away = darker)
sea_jitter     = 10;       // px each puff is nudged off its cell's centre
sea_scale      = [1.8, 2.3];
sea_edges_front = false;   // true: the puffs touching the floor overlap its edges. false: every puff's behind the tiles

// --- state ---
if (!variable_global_exists("plat_cloud") || !is_struct(global.plat_cloud))
    global.plat_cloud = { on: false, gap: 0 };
init        = false;
clouds      = [];
cloud_y     = 0;           // room y of the cloud's top line
spd         = 0;
vspd        = 0;
y_scale     = 0;
cloud_angle = 0;
hold        = false;       // dropped in from the room above: it waits until they've landed
puffs       = [];          // "sea"

/// "rise": the two rings (Deltarune's User Event 1)
build_rings = function()
{
    clouds = [];
    var _c = 0;
    for (var r = 0; r < 2; r++)
    {
        var _a = 0;
        repeat (ring_count[r])
        {
            array_push(clouds, { num: _c, base_angle: _a, angle: _a, ring: r, z: 0, x: 0, y: 0 });
            _c++;
            _a += 360 / ring_count[r];
        }
    }
}

/// "sea": a puff in every empty cell around the floor. the back instance keeps the rest, and makes the front one for the edges
build_sea = function()
{
    puffs = [];
    var _lay = layer_exists(sea_layer) ? layer_get_id(sea_layer) : -1;
    var _tm  = (_lay != -1) ? layer_tilemap_get_id(_lay) : -1;
    if (_tm == -1) { show_debug_message("obj_plat_cloud: no tile layer called " + sea_layer); return; }
    var _tw = tilemap_get_tile_width(_tm), _th = tilemap_get_tile_height(_tm);
    var _ox = tilemap_get_x(_tm), _oy = tilemap_get_y(_tm);
    var _cols = ceil(room_width / _tw), _rows = ceil(room_height / _th);

    var _filled = function(_tm, _c, _r, _cols, _rows)
    {
        if (_c < 0 || _r < 0 || _c >= _cols || _r >= _rows) return false;
        var _d = tilemap_get(_tm, _c, _r);
        return _d != -1 && (_d & tile_index_mask) != 0;
    };

    var _n = (spr_puff != -1) ? sprite_get_number(spr_puff) : 1;
    for (var r = 0; r < _rows; r++)
    {
        for (var c = 0; c < _cols; c++)
        {
            if (_filled(_tm, c, r, _cols, _rows)) continue;
            var _edge = _filled(_tm, c - 1, r, _cols, _rows) || _filled(_tm, c + 1, r, _cols, _rows)
                     || _filled(_tm, c, r - 1, _cols, _rows) || _filled(_tm, c, r + 1, _cols, _rows);
            if (sea_edges_front && _edge != front) continue;   // split between the back and front instances
            var _y = _oy + (r + 0.5) * _th + random_range(-sea_jitter, sea_jitter);
            var _light = lerp(sea_far_light, sea_near_light, clamp(_y / room_height, 0, 1)) + random_range(-0.05, 0.05);
            array_push(puffs, {
                x: _ox + (c + 0.5) * _tw + random_range(-sea_jitter, sea_jitter),
                y: _y,
                img: irandom(_n - 1),
                sc: random_range(sea_scale[0], sea_scale[1]),
                col: merge_color(c_black, c_white, clamp(_light, 0, 1)),
                base_angle: random(360)
            });
        }
    }
    // back to front, so the lower ones overlap the ones above them
    array_sort(puffs, function(_a, _b) { return sign(_a.y - _b.y); });
}

/// puts _spr frame _img with its top-left at (_x, _y), whatever its origin is
draw_topleft = function(_spr, _img, _x, _y, _xs, _ys, _col)
{
    draw_sprite_ext(_spr, _img, _x + sprite_get_xoffset(_spr) * _xs, _y + sprite_get_yoffset(_spr) * _ys, _xs, _ys, 0, _col, 1);
}

/// "rise": one half of the cloud (Deltarune's render, front or back), drawn so the view's top-left lands on (_ox, _oy)
/// and one view pixel is _k pixels wide (Post Draw: the window. Draw: the room, _k = 1)
draw_pass = function(_front, _ox, _oy, _k)
{
    if (mode != "rise" || !global.plat_cloud.on || hold) return;
    var _vw = camera_get_view_width(view_camera[0]);
    var _vh = camera_get_view_height(view_camera[0]);
    var _y0 = cloud_y - camera_get_view_y(view_camera[0]);   // the cloud's top line, on screen
    if (_y0 > _vh + 250) return;                               // still well below the screen
    var _cx = _vw / 2;
    var _t  = current_time;

    var _order = _front ? [0, 1] : [1, 0];
    for (var o = 0; o < 2; o++)
    {
        var _ri = _order[o];
        var _d  = ring_dr[_ri];
        var _ds = (_d - ring_dr[0]) / (ring_dr[1] - ring_dr[0]);   // 0 inner, 1 outer

        // the black mass
        if (spr_bg != -1)
        {
            var _bxs = _vw / sprite_get_width(spr_bg);
            if (!_front)
            {
                var _by = _y0 + 30 * (1 - y_scale) - _d * 0.2 - 10;
                draw_topleft(spr_bg, 0, _ox, _oy + _by * _k, _bxs * _k, 2 * (1 + (1 - _ds) * 0.1) * _k, c_black);
            }
            else if (_ri == 1)
            {
                var _by = _y0 - 100 * (1 - y_scale) + _d * 0.3;
                draw_topleft(spr_bg, (y_scale > 0 && sprite_get_number(spr_bg) > 1) ? 1 : 0, _ox, _oy + _by * _k, _bxs * _k, 2 * _k, c_black);
            }
        }

        // the puffs on this ring, on this side
        if (spr_puff == -1) continue;
        for (var i = 0; i < array_length(clouds); i++)
        {
            var _c = clouds[i];
            if (_c.ring != _ri) continue;
            if ((_c.z < 0) != _front) continue;
            var _px = _cx + _c.x + sin(_t / 500 + _c.base_angle) * bob_x;
            var _py = _y0 + _c.y + sin(_t / 250 + _c.base_angle * 0.05) * bob_y;
            var _col = merge_color(c_black, c_white, clamp(0.55 - 0.45 * dsin(_c.angle), 0, 1));
            var _img = _c.num mod sprite_get_number(spr_puff);
            if (outline && spr_puff_ol != -1)
                draw_sprite_ext(spr_puff_ol, _c.num mod sprite_get_number(spr_puff_ol), _ox + _px * _k, _oy + (_py - 1) * _k, puff_scale * _k, puff_scale * _k, 0, _col, 1);
            draw_sprite_ext(spr_puff, _img, _ox + _px * _k, _oy + _py * _k, puff_scale * _k, puff_scale * _k, 0, _col, 1);
        }
    }
}