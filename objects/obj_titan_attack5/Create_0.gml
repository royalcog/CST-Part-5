event_inherited();
// Titan attack 5: Titan Spawn attack 1 again (Deltarune's darkshapes), twice as long. halfway through, a Rude Buster
// comes up from off the bottom of the screen (Susie, from the bottom of the tower) and breaks the box open: the rest of
// it is a whole-screen remix. copies pour in from every edge of the screen, faster, with red shapes mixed in and rings
// of them closing in around the SOUL. the SOUL's light grows to cope
attack_duration = 1440;   // (attack 1's 720, doubled)
break_at        = 720;    // frames in that the box breaks
// --- the whole-screen half ---
full_gap        = 18;     // frames between copies (the box half: 48)
full_scale      = 1;      // their size (the box half: 0.85)
red_every_full  = 4;      // every Nth one's a red shape
edge_out        = 30;     // px outside the screen edge they come in from
burst_every     = 150;    // frames between rings closing in on the SOUL...
burst_n         = 6;      // ...of this many...
burst_r         = 230;    // ...starting this far out
full_aura       = 64;     // the SOUL's light (Brighten's size)
end_fade        = 40;     // frames everything fades at the end
// --- the Rude Buster ---
buster_from     = { x: 140, y: 560 };   // where it comes up from (screen px: off the bottom of the screen)

phase  = "box";
full_t = 0;
end_t  = 0;
global.attack_fullscreen = 0;

/// a copy (or a red shape) at (_x, _y), heading for the SOUL
spawn_at = function(_x, _y, _red)
{
    if (_red)
        with (instance_create_depth(_x, _y, depth, obj_redshape)) { ctrl = other.id; damage = other.damage; }
    else with (instance_create_depth(_x, _y, depth, obj_darkshape))
    {
        ctrl        = other.id;
        scalefactor = other.full_scale;
        damage      = other.damage;
        dir         = instance_exists(obj_soul) ? point_direction(x, y, obj_soul.x, obj_soul.y) : 0;
    }
    spawn_counter++;
}
/// in from a random edge of the screen
spawn_edge = function()
{
    var _vx = camera_get_view_x(view_camera[0]), _vy = camera_get_view_y(view_camera[0]);
    var _vw = camera_get_view_width(view_camera[0]), _vh = camera_get_view_height(view_camera[0]);
    var _x = 0, _y = 0;
    switch (irandom(3))
    {
        case 0:  _x = _vx - edge_out;       _y = _vy + random(_vh);     break;
        case 1:  _x = _vx + _vw + edge_out; _y = _vy + random(_vh);     break;
        case 2:  _x = _vx + random(_vw);    _y = _vy - edge_out;        break;
        default: _x = _vx + random(_vw);    _y = _vy + _vh + edge_out;  break;
    }
    spawn_at(_x, _y, red_every_full > 0 && (spawn_counter mod red_every_full) == red_every_full - 1);
}
/// a ring of them all round the SOUL
spawn_burst = function()
{
    if (!instance_exists(obj_soul)) return;
    var _a0 = random(360);
    for (var i = 0; i < burst_n; i++)
    {
        var _a = _a0 + i * 360 / burst_n;
        spawn_at(obj_soul.x + lengthdir_x(burst_r, _a), obj_soul.y + lengthdir_y(burst_r, _a), false);
    }
    audio_play_sound(snd_dark_odd, 1, false, 0.6);
}
/// the Rude Buster, from off the bottom of the screen, at the box
break_box = function()
{
    global.attack_fullscreen = 1;   // (from now on the copies don't need the box)
    with (obj_susie)
    {
        visible = false;
        image_angle = 0;
        image_xscale = 2;
        x = camera_get_view_x(view_camera[0]) + other.buster_from.x;
        y = camera_get_view_y(view_camera[0]) + other.buster_from.y;
    }
    with (instance_create_depth(0, 0, -5200, obj_rude_buster)) break_on_hit = true;
}