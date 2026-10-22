if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }

// the bomb itself hurts on contact until it bursts
var _r = bomb_hit_radius * (image_xscale / bomb_scale);
if (instance_exists(obj_soul) && !obj_soul.invulnerable
 && point_distance(x, y, obj_soul.x, obj_soul.y) <= _r)
{
    scr_soul_take_hit(bomb_damage, c_white, c_white);
}

switch (state)
{
    case "toss":
        timer++;
        var _t = min(timer / toss_frames, 1);
        x = lerp(start_x, land_x, _t);
        y = lerp(start_y, land_y, _t) - arc_height * 4 * _t * (1 - _t);
        image_angle += spin_speed * spin_dir;

        if (_t >= 1)
        {
            image_angle = 90; // sit upright (spr_spade points right)
            timer = 0;
            state = "fuse";
        }
    break;

    case "fuse":
        timer++;
        var _ft = timer / fuse_frames;

        var _s = bomb_scale * (1 + fuse_swell * _ft);
        image_xscale = _s;
        image_yscale = _s;

        if (flash_timer > 0) flash_timer--;
        flash_countdown--;
        if (flash_countdown <= 0)
        {
            flash_timer = 2;
            flash_countdown = round(lerp(flash_slow, flash_fast, _ft));
            if (fuse_sound != -1) audio_play_sound(fuse_sound, 5, false, fuse_gain);
        }

        if (timer >= fuse_frames)
        {
            // ring of spades, rotated randomly each time so the gaps aren't always in the same place
            var _offset = random(360);
            for (var i = 0; i < ring_count; i++)
            {
                var _b = instance_create_depth(x, y, depth, obj_spade_burst);
                _b.move_dir    = _offset + i * 360 / ring_count;
                _b.image_angle = _b.move_dir;
                _b.move_speed  = ring_speed;
                _b.damage      = ring_damage;
                _b.hit_radius  = ring_hit_radius;
            }

            if (burst_sound != -1) audio_play_sound(burst_sound, 8, false);
            scr_camera_shake(2, 6);
            instance_destroy();
        }
    break;
}