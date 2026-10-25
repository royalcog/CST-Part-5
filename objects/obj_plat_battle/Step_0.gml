t++;

switch (state)
{
    case "intro":
        fade = min(1, fade + 1 / fade_len);
        if (t == 20)
        {
            // the big one flies in from above
            boss = instance_create_depth(scr_plat_wrap(arena.cx), arena.t - 140, -150, obj_plat_titanspawn);
            with (boss)
            {
                boss        = true;
                hp          = other.boss_hits;
                leader_only = true;
                arena       = other.arena;
                path_y      = other.arena.t + 110;
                path_ax     = other.arena.half - 110;
                base_y      = y;
            }
        }
        if (instance_exists(boss) && (boss.y >= arena.t + 60 || t >= 140))
        {
            global.plat_lock = false;
            state = "fight";
            t = 0;
        }
    break;

    case "fight":
    {
        fight_t++;
        if (!instance_exists(boss) || boss.dying) { state = "end"; t = 0; break; }

        // rainbow: after so many hits it can't be hit for a while
        var _hits = boss_hits - boss.hp;
        if (boss.invincible)
        {
            if (--rainbow_t <= 0) boss.invincible = false;
        }
        else if (ri < array_length(rainbow_at) && _hits >= rainbow_at[ri] && boss.hurt_t <= 0)
        {
            ri++;
            if (fight_t < no_rainbow_after)
            {
                boss.invincible = true;
                rainbow_t = rainbow_len;
                if (rainbow_sound != noone) audio_play_sound(rainbow_sound, 1, false);
            }
        }

        // fish, faster while it's rainbow
        fish_t++;
        var _every = boss.invincible ? fish_every_rb : fish_every;
        if (fight_t >= fish_first && fish_t >= _every)
        {
            if (random(1) < fish_vert) spawn_fish_vert(choose(1, 1, -1));   // mostly down, sometimes up
            else spawn_fish(choose(-1, 1));
            fish_t = 0;
        }
    }
    break;

    case "end":
        // the fish swim off, then the box opens back up
        with (obj_plat_titanfish) fading = true;
        if (t >= end_wait && !instance_exists(boss))
        {
            fade = max(0, fade - 1 / fade_len);
            ctl.wrap_target = 1;
            if (fade <= 0)
            {
                global.plat_arena = undefined;
                ctl.cam_locked  = false;
                ctl.cam_release = 40;
                ctl.battle_on   = false;
                ctl.spawn_t     = 0;
                instance_destroy();
            }
        }
    break;
}