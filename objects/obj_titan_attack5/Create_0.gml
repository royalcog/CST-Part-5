event_inherited();
// Titan attack 5: Titan Spawn attack 1 again (Deltarune's darkshapes), twice as long. halfway through, Ralsei throws a
// fireball at the box and breaks it open: the rest of it is a whole-screen remix. copies pour in from every edge of the
// screen, faster, with red shapes mixed in and rings of them closing in around the SOUL. the SOUL's light grows to cope
attack_duration = 1440;   // (attack 1's 720, doubled)
break_at        = 720;    // frames in that he starts his spell (the box breaks when the fireball gets there)
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
// --- Ralsei's fireball ---
cast_sprite     = spr_ralsei_spell;
cast_speed      = 0.25;   // its frames a frame
cast_frame      = 6;      // the frame the fireball leaves his hand on
cast_hold       = 20;     // frames he holds the last frame before going back to his idle
hand            = { x: 14, y: -36 };   // his raised hand in his spell's throw frame, in his sprite's px from his origin
fb_sprite       = spr_plat_fireball;
fb_scale        = 2;
fb_speed        = 9;
fb_trail        = 8;
fb_glow         = 26;     // px
fb_sound        = snd_firespell;

phase    = "box";
full_t   = 0;
end_t    = 0;
cast     = undefined;     // { t, thrown, done }
fireball = undefined;     // { x, y, dir, frame, trail }
boom     = undefined;     // { x, y, f }
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

/// Ralsei starts his spell
cast_start = function()
{
    cast = { t: 0, thrown: false, done: false };
    with (obj_ralsei)
    {
        sprite_index = other.cast_sprite; image_index = 0; image_speed = 0;
        if (variable_instance_exists(id, "last_sprite")) last_sprite = sprite_index;
    }
}
/// the fireball leaves his hand
throw_fireball = function(_x, _y)
{
    fireball = { x: _x, y: _y, dir: 0, frame: 0, trail: [] };
    audio_play_sound(fb_sound, 1, false);
}
/// his spell's frames, and the fireball flying at the box
cast_update = function()
{
    if (cast != undefined && !cast.done)
    {
        var _r = instance_find(obj_ralsei, 0);
        if (_r == noone)
        {
            cast.done = true;
            if (!cast.thrown) { var _v = camera_get_view_x(view_camera[0]); throw_fireball(_v + 420, camera_get_view_y(view_camera[0]) + 200); }
        }
        else
        {
            var _last = sprite_get_number(cast_sprite) - 1;
            _r.image_speed = 0;
            _r.image_index = min(_r.image_index + cast_speed, _last);
            if (!cast.thrown && _r.image_index >= cast_frame)
            {
                cast.thrown = true;
                throw_fireball(_r.x + hand.x * _r.image_xscale, _r.y + hand.y * _r.image_yscale);
            }
            if (cast.thrown && _r.image_index >= _last && ++cast.t >= cast_hold)
            {
                cast.done = true;
                with (_r)
                {
                    sprite_index = spr_ralsei_battle_idle_mad; image_index = 0; image_speed = 1;
                    if (variable_instance_exists(id, "last_sprite")) last_sprite = sprite_index;
                }
            }
        }
    }
    if (fireball != undefined)
    {
        var _f = fireball;
        array_insert(_f.trail, 0, { x: _f.x, y: _f.y });
        if (array_length(_f.trail) > fb_trail) array_pop(_f.trail);
        _f.frame += 0.3;
        if (!instance_exists(obj_battlebox)) { fireball = undefined; return; }
        var _c = scr_box_center();
        _f.dir = point_direction(_f.x, _f.y, _c.x, _c.y);
        if (point_distance(_f.x, _f.y, _c.x, _c.y) <= fb_speed) { fireball = undefined; break_box(_c.x, _c.y); }
        else { _f.x += lengthdir_x(fb_speed, _f.dir); _f.y += lengthdir_y(fb_speed, _f.dir); }
    }
}
/// it hits: the box shatters (obj_rude_buster's pieces, sounds, shake and flash, made and set off straight away)
break_box = function(_x, _y)
{
    global.attack_fullscreen = 1;   // (from now on the copies don't need the box)
    phase = "breaking";
    boom  = { x: _x, y: _y, f: 0 };
    audio_play_sound(snd_explosion, 1, false);
    // (obj_rude_buster's Create puts Susie in her swing: she isn't here, so she's put back how she was)
    var _keep = undefined;
    with (obj_susie) _keep = { spr: sprite_index, img: image_index, spd: image_speed, vis: visible,
                               loop: variable_instance_exists(id, "anim_loop") ? anim_loop : true };
    var _b = instance_create_depth(0, 0, -5200, obj_rude_buster);
    with (_b) { susie_done = true; break_box(); }
    if (_keep != undefined) with (obj_susie)
    {
        sprite_index = _keep.spr; image_index = _keep.img; image_speed = _keep.spd; visible = _keep.vis; anim_loop = _keep.loop;
        if (variable_instance_exists(id, "last_sprite")) last_sprite = sprite_index;
    }
}