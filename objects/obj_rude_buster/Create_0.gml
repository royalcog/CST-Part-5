// --- tuning ---
susie_sprite    = spr_susie_rudebuster;
fire_frame      = 7;
projectile      = spr_rudebuster_projectile;
proj_scale      = 2;
proj_anim_speed = 10 / 60;
spawn_x         = 38;   // where it leaves the swing, in her sprite's px from her origin
spawn_y         = -41;
proj_speed      = 14;
trail_len       = 6;
launch_sound    = snd_boost;
break_sounds    = [snd_glassbreak, snd_impact];
break_shake     = 6;
chunks_x        = 6;
chunks_y        = 5;
debris_gravity  = 0.35;
target_x     = undefined; // set both to aim somewhere other than the box's center
target_y     = undefined;
break_on_hit = true;      // false: it just lands (sets landed) and the box stays
landed       = false;

// --- state ---
state      = "windup"; // windup -> fly -> broken
broken     = false;    // other objects wait on this
proj       = undefined;
debris     = [];
flash      = 0;
susie_done = !instance_exists(obj_susie);

if (instance_exists(obj_susie))
{
    with (obj_susie)
    {
        sprite_index = other.susie_sprite;
        last_sprite  = sprite_index;
        image_index  = 0;
        image_speed  = 1;
        anim_loop    = false;
    }
}

view_rect = function()
{
    var _cam = view_camera[0];
    var _x = instance_exists(obj_camera_controller) ? obj_camera_controller.cam_x : camera_get_view_x(_cam);
    var _y = instance_exists(obj_camera_controller) ? obj_camera_controller.cam_y : camera_get_view_y(_cam);
    return { x1: _x, y1: _y, x2: _x + camera_get_view_width(_cam), y2: _y + camera_get_view_height(_cam) };
}

launch = function()
{
    var _sx = instance_exists(obj_susie) ? obj_susie.x + spawn_x * obj_susie.image_xscale : 0;
    var _sy = instance_exists(obj_susie) ? obj_susie.y + spawn_y * obj_susie.image_yscale : 0;
    var _tx, _ty;
    if (!is_undefined(target_x)) { _tx = target_x; _ty = target_y; }
    else if (instance_exists(obj_battlebox)) { var _c = scr_box_center(); _tx = _c.x; _ty = _c.y; }
    else { var _v = view_rect(); _tx = (_v.x1 + _v.x2) / 2; _ty = (_v.y1 + _v.y2) / 2; }

    proj = { x: _sx, y: _sy, tx: _tx, ty: _ty, dir: point_direction(_sx, _sy, _tx, _ty), frame: 0, trail: [] };
    if (launch_sound != noone) audio_play_sound(launch_sound, 1, false);
    state = "fly";
}

break_box = function()
{
    if (instance_exists(obj_battlebox))
    {
        var _c = scr_box_center();
        with (obj_battlebox)
        {
            var _pw = raw_width  / other.chunks_x;
            var _ph = raw_height / other.chunks_y;
            for (var i = 0; i < other.chunks_x; i++)
            for (var j = 0; j < other.chunks_y; j++)
            {
                var _l  = floor(i * _pw), _tt = floor(j * _ph);
                var _w  = floor((i + 1) * _pw) - _l, _h = floor((j + 1) * _ph) - _tt;
                var _wx = x + _l * image_xscale, _wy = y + _tt * image_yscale;
                var _d  = point_direction(_c.x, _c.y, _wx + _w * image_xscale / 2, _wy + _h * image_yscale / 2);
                var _s  = random_range(2, 6);
                array_push(other.debris, { spr: sprite_index, img: image_index,
                    l: _l, t: _tt, w: _w, h: _h, xs: image_xscale, ys: image_yscale,
                    x: _wx, y: _wy, vx: lengthdir_x(_s, _d), vy: lengthdir_y(_s, _d) - random_range(3, 6),
                    rot: 0, vr: random_range(-6, 6) });
            }
        }
        instance_destroy(obj_battlebox);
    }

    for (var i = 0; i < array_length(break_sounds); i++) audio_play_sound(break_sounds[i], 1, false);
    scr_camera_shake(break_shake, 20);
    flash  = 1;
    proj   = undefined;
    broken = true;
	landed = true;
    state  = "broken";
}