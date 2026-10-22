// the Knight floats (his own bob/trail are off, so he doesn't leave shadows)
if (instance_exists(knight))
{
    bob += bob_speed;
    knight.y = knight_y0 + sin(bob) * bob_amp;
}

// the white streak
if (flash_t >= 0 && ++flash_t > flash_time) flash_t = -1;

// the swords
if (swords_spawned)
{
    var _all_in = true, _all_gone = true;
    for (var i = 0; i < array_length(swords); i++)
    {
        var _s = swords[i];
        if (_s.gone) continue;
        _all_gone = false;

        if (_s.delay > 0)
        {
            _s.delay--;
            _all_in = false;
            if (_s.delay == 0 && i == 0 && sword_appear_sound != noone) audio_play_sound(sword_appear_sound, 1, false);
            continue;
        }
        _s.alpha = min(1, _s.alpha + 1 / sword_fade_in);
        if (_s.alpha < 1) _all_in = false;

        if (_s.thrown)
        {
            if (_s.wait > 0) { _s.wait--; continue; }   // still inside the streak
            _s.vy = min(sword_max_speed, _s.vy + sword_accel);
            _s.y += _s.vy;
            // fully under the platform edge (the floor tiles cover it), so it's gone
            var _top = _s.y - sprite_get_yoffset(spr_roark_sword2) * sword_scale;
            if (_top > edge_y) _s.gone = true;
        }
    }
        if (_all_in) swords_all_in = true;

    // once they're all in, he throws when the sound gets to the throw
    if (swords_all_in && !firing)
    {
        hold_t++;
        var _ready = (snd_drop >= 0 && audio_is_playing(snd_drop))
                   ? audio_sound_get_track_position(snd_drop) >= sword_throw_at
                   : hold_t >= sword_hold;   // no sound: just a fixed hold
        if (_ready)
        {
            firing = true;
            fire_i = 0;
            fire_t = 0;
            flash_t = 0;
            if (instance_exists(knight)) knight.image_speed = throw_anim; // finish the swing
        }
    }
    if (firing && fire_i < array_length(swords))
    {
        if (fire_t <= 0)
        {
            swords[fire_i].thrown = true;
            swords[fire_i].wait   = sword_fall_delay;
            if (sword_throw_sound != noone) audio_play_sound(sword_throw_sound, 1, false);
            fire_i++;
            fire_t = sword_fire_gap;
        }
        else fire_t--;
    }

    // the first sword going under the platform is the impact: the Titan scene starts there
    if (firing && state == "throw" && swords[0].gone) state = "done";
}

switch (state)
{
    case "setup":
    {
        var _bottom = camera_get_view_y(view_camera[0]) + camera_get_view_height(view_camera[0]) + 50;

        var _s = instance_exists(obj_susie)  ? obj_susie  : instance_create_layer(susie_x,  _bottom, "Instances", obj_susie);
        var _r = instance_exists(obj_ralsei) ? obj_ralsei : instance_create_layer(ralsei_x, _bottom, "Instances", obj_ralsei);

        _s.sprite_index = spr_susie_walk_up;
        _r.sprite_index = spr_ralsei_walk_up;

        var _pair = [ [_s, susie_x], [_r, ralsei_x] ];
        for (var i = 0; i < 2; i++)
        {
            var _o = _pair[i][0];
            _o.last_sprite = _o.sprite_index; // already placed, so scr_auto_keep_feet leaves it alone
            _o.anim_loop   = true;
            _o.image_index = 0;
            _o.image_speed = walk_anim;
            _o.image_alpha = 1;
            _o.visible     = true;
            set_feet(_o, _pair[i][1], _bottom);
        }

        // the Knight, already floating over the fountain
        knight = instance_exists(obj_knight) ? instance_find(obj_knight, 0) : instance_create_layer(0, 0, "Instances", obj_knight);
        with (knight)
        {
            ball_phase    = 0;     // no built-in bob, no shadow trail
            reverse_phase = 0;
            visible       = true;
            image_alpha   = 1;
            sprite_index  = spr_roark_beckon;
            image_index   = 0;
            image_speed   = 0;
            anim_loop     = true;
        }
        knight.x  = knight_x      - (knight_beckon_head.x - sprite_get_xoffset(spr_roark_beckon)) * knight.image_xscale;
        knight_y0 = knight_head_y - (knight_beckon_head.y - sprite_get_yoffset(spr_roark_beckon)) * knight.image_yscale;
        knight.y  = knight_y0;

        state = "walk";
    }
    break;

    case "walk":
    {
        var _a = step_up(obj_susie,  stand_y);
        var _b = step_up(obj_ralsei, stand_y);
        if (_a && _b && !instance_exists(obj_cutscenefade))
        {
            // he beckons them over
            knight.image_index = 0;
            knight.image_speed = beckon_anim;
            beckon_count = 0;
            beckon_last  = 0;
            state = "beckon";
        }
    }
    break;

    case "beckon":
    {
        var _f = knight.image_index;
        if (_f < beckon_last) beckon_count++; // wrapped back to frame 0 = one beckon done
        beckon_last = _f;
        if (beckon_count >= beckon_loops)
        {
            knight.image_speed = 0;
            knight.image_index = 0;
            state = "pause";
            t = 0;
        }
    }
    break;

    case "pause":
        if (++t >= talk_wait)
        {
            create_textbox("rm2_ralsei_plead");
            state = "talk";
        }
    break;

    case "talk":
        if (!instance_exists(obj_textbox)) { state = "throw_wait"; t = 0; }
    break;

    case "throw_wait":
        if (++t >= throw_wait)
        {
            stop_knight_appear_music(appear_fade_out);
            knight_pose(spr_roark_throw_sword, knight_beckon_head, knight_throw_head);
            knight.image_speed = throw_anim;
            knight.anim_loop   = false; // obj_knight holds the last frame
			
            // they both go shocked
            if (ralsei_shock_sprite != noone && instance_exists(obj_ralsei) && obj_ralsei.sprite_index == spr_ralsei_walk_up)
                pose_on_foot(obj_ralsei, ralsei_shock_sprite, ralsei_walk_foot, ralsei_shock_foot);
            if (susie_shock_sprite != noone && instance_exists(obj_susie) && obj_susie.sprite_index == spr_susie_walk_up)
                pose_on_foot(obj_susie, susie_shock_sprite, susie_walk_foot, susie_shock_foot);

            state = "throw";
        }
    break;

    case "throw":
        // the scene's audio starts partway into his swing
        if (snd_drop < 0 && sword_drop_sound != noone && knight.image_index >= sword_spawn_frame - (sword_spawn_frame - sword_sound_frame))
            snd_drop = audio_play_sound(sword_drop_sound, 1, false);

        // arm up: the swords appear over his head, one by one left to right
        if (!swords_spawned && knight.image_index >= sword_spawn_frame)
        {
            for (var i = 0; i < sword_count; i++)
            {
                array_push(swords, {
                    x: lerp(sword_x_from, sword_x_to, (sword_count > 1) ? i / (sword_count - 1) : 0.5),
                    y: sword_y,
                    alpha: 0,
                    vy: 0,
                    delay: 1 + i * sword_stagger,
                    thrown: false,
                    wait: 0,
                    gone: false
                });
            }
            swords_spawned = true;
        }
        // hold his arm up until the throws start
        if (!firing && knight.image_index >= sword_hold_frame)
        {
            knight.image_speed = 0;
            knight.image_index = sword_hold_frame;
        }
        // the throws and the finish are handled above, with the swords
    break;

    case "done":
        // the swords are down: the Titan comes up out of the fountain
        if (!layer_exists("Titan")) layer_create(345, "Titan");
        if (!instance_exists(obj_titan_spawn)) instance_create_layer(0, 0, "Titan", obj_titan_spawn);
        state = "titan";
    break;

    case "titan":
        // obj_titan_spawn runs the rest. cutscene_lock stays on
    break;
}