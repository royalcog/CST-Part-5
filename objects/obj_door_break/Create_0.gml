// the castle door in Tiles_1 gets cut, then shatters. obj_rm_one_scene calls slash()
depth = 250; // over the tiles, under the cauldron and everyone

// the door panels in the tiles (the base of the door is 380,196)
door_x1 = 338;  door_y1 = 90;
door_x2 = 426;  door_y2 = 197;
open_radius = 18;
open_color  = c_black;

// the cut: top-right to bottom-left across the door
cut_x1 = door_x2 + 16;  cut_y1 = door_y1 - 8;
cut_x2 = door_x1 - 16;  cut_y2 = door_y2 - 14;
cut_width   = 14;
cut_frames  = 12;
break_delay = 8;   // frames the door shakes on its cut before it goes
cut_sound   = snd_knight_cut;

// the shatter
shard_cols      = 6;     // the door's cut into a cols x rows grid, each cell into 2 triangles
shard_rows      = 7;
shard_jitter    = 0.35;  // how wonky the cracks are (0 = a neat grid)
shard_burst     = 4.5;   // how hard they fly out from the middle
shard_pop       = 3;     // extra upward kick
shard_gravity   = 0.32;
shard_spin      = 12;
shard_floor_min = 4;     // they land this far in front of the base of the door...
shard_floor_max = 46;    // ...up to this far
shard_life      = 85;
shard_fade      = 25;    // last frames of shard_life spent fading

// --- state ---
state    = "idle";  // idle -> cut -> broken
t        = 0;
door_spr = -1;      // the door's own pixels, grabbed off the tilemap the first Draw
shards   = [];
flash    = 0;

slash = function()
{
    if (state != "idle") return;
    state = "cut";
    t = 0;
    flash = 1;
    audio_play_sound(cut_sound, 1, false);
}

/// one triangle of the door. _p = [[x,y],[x,y],[x,y]] in the door's own pixels
add_shard = function(_p)
{
    var _w = door_x2 - door_x1, _h = door_y2 - door_y1;
    var _mx = (_p[0][0] + _p[1][0] + _p[2][0]) / 3;
    var _my = (_p[0][1] + _p[1][1] + _p[2][1]) / 3;

    var _ang = point_direction(_w / 2, _h * 0.5, _mx, _my);
    var _spd = shard_burst * random_range(0.5, 1);
    array_push(shards, {
        x: door_x1 + _mx, y: door_y1 + _my,
        lx: [_p[0][0] - _mx, _p[1][0] - _mx, _p[2][0] - _mx],
        ly: [_p[0][1] - _my, _p[1][1] - _my, _p[2][1] - _my],
        u:  [_p[0][0], _p[1][0], _p[2][0]],
        v:  [_p[0][1], _p[1][1], _p[2][1]],
        vx: lengthdir_x(_spd, _ang) * 0.8 + random_range(-0.8, 0.8),
        vy: lengthdir_y(_spd, _ang) * 0.5 - random_range(1, shard_pop),
        rot: 0, vr: random_range(-shard_spin, shard_spin),
        floor_y: door_y2 + random_range(shard_floor_min, shard_floor_max),
        bounced: false, landed: false, t: 0
    });
}

do_break = function()
{
    state = "broken";
    t = 0;
    flash = 1;
    audio_play_sound(snd_glassbreak, 1, false);
    audio_play_sound(snd_impact, 1, false);
    scr_camera_shake(5, 15);

    // a jittered grid (edge points stay on the edges so the pieces fill the door exactly)
    var _w = door_x2 - door_x1, _h = door_y2 - door_y1;
    var _c = shard_cols + 1;
    var _g = [];
    for (var j = 0; j <= shard_rows; j++)
    for (var i = 0; i <= shard_cols; i++)
    {
        var _px = _w * i / shard_cols, _py = _h * j / shard_rows;
        if (i > 0 && i < shard_cols) _px += random_range(-1, 1) * shard_jitter * _w / shard_cols;
        if (j > 0 && j < shard_rows) _py += random_range(-1, 1) * shard_jitter * _h / shard_rows;
        _g[j * _c + i] = [_px, _py];
    }

    for (var j = 0; j < shard_rows; j++)
    for (var i = 0; i < shard_cols; i++)
    {
        var _a = _g[j * _c + i], _b = _g[j * _c + i + 1];
        var _d = _g[(j + 1) * _c + i], _e = _g[(j + 1) * _c + i + 1];
        if (irandom(1)) { add_shard([_a, _b, _e]); add_shard([_a, _e, _d]); }
        else            { add_shard([_a, _b, _d]); add_shard([_b, _e, _d]); }
    }
}