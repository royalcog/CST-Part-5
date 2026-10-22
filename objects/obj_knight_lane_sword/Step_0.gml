if (needs_box && (!instance_exists(obj_battlebox) || obj_battlebox.state == "closing"))
{
    alpha -= 0.1;
    if (alpha <= 0) instance_destroy();
    exit;
}

switch (state)
{
    case "charge":
        t++;
        alpha = min(alpha + 1 / fade_in_frames, 1);
        if (t >= charge)
        {
            vx = lengthdir_x(launch_speed, dir);
            vy = lengthdir_y(launch_speed, dir);
            state = "fly";
            if (fire_sound != noone && get_timer() - global.lane_sword_snd_time > 40000)
            {
                audio_play_sound(fire_sound, 1, false);
                global.lane_sword_snd_time = get_timer();
            }
        }
    break;

    case "fly":
        array_insert(trail, 0, { x: x, y: y });
        if (array_length(trail) > trail_len) array_pop(trail);

        var _px = x, _py = y;
        x += vx;
        y += vy;
        travelled += launch_speed;

        var _hx = lengthdir_x(half, dir), _hy = lengthdir_y(half, dir);

        // Susie's barrier stops it dead
        var _block = scr_barrier_hit_segment(_px + _hx, _py + _hy, x + _hx, y + _hy);
        if (_block != undefined)
        {
            shatter_x = _block.x;
            shatter_y = _block.y;
            state = "shatter";
            if (shatter_sound != noone && get_timer() - global.lane_shatter_snd_time > 40000)
            {
                audio_play_sound(shatter_sound, 1, false, 0.6);
                global.lane_shatter_snd_time = get_timer();
            }
            break;
        }

        // check the whole stretch it swept this frame so it can't skip the soul
        if (instance_exists(obj_soul) && !obj_soul.invulnerable && !scr_soul_in_barrier()
            && scr_point_segment_distance(obj_soul.x, obj_soul.y, _px - _hx, _py - _hy, x + _hx, y + _hy) <= hit_radius)
        {
            scr_soul_take_hit(damage, hit_color_top, hit_color_bottom);
        }

        if (travelled >= travel_max) instance_destroy();
    break;

    case "shatter":
        shatter_t++;
        if (shatter_t >= shatter_frames) instance_destroy();
    break;
}