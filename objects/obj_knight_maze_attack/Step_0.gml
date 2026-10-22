var _v   = view_rect();
var _hin = keyboard_check(vk_right) - keyboard_check(vk_left);
var _vin = keyboard_check(vk_down)  - keyboard_check(vk_up);
var _spd = instance_exists(obj_soul) ? obj_soul.move_speed : 2;

// pieces of the box/walls fall whatever phase we're in
for (var i = array_length(debris) - 1; i >= 0; i--)
{
    var _d = debris[i];
    _d.vy  += debris_gravity;
    _d.x   += _d.vx;
    _d.y   += _d.vy;
    _d.rot += _d.vr;
    if (_d.y > _v.y2 + 200) array_delete(debris, i, 1);
}
break_flash = max(break_flash - 0.05, 0);

// Susie goes back to idle once her Rude Buster swing has fully played out
if (instance_exists(obj_susie) && obj_susie.sprite_index == buster_sprite && obj_susie.image_speed == 0)
{
    with (obj_susie)
    {
        sprite_index = spr_susie_battle_idle;
        last_sprite  = sprite_index;
        image_index  = 0;
        image_speed  = 1;
        anim_loop    = true;
    }
}

switch (state)
{
    case "grow":
        if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
        if (recenter_box) obj_battlebox.box_base_y = lerp(obj_battlebox.box_base_y, target_base_y, obj_battlebox.scale_speed);
        if (scr_box_scale_settled())
        {
            if (recenter_box) obj_battlebox.box_base_y = target_base_y;
            timer--;
            if (timer <= 0) start_maze();
        }
    break;

    case "maze":
    case "cheater_talk":
    case "buster_windup":
    case "buster_fly":
        if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
        t++;
        wall_alpha = min(wall_alpha + 1 / wall_fade_in, 1);

        if (instance_exists(obj_soul)) move_soul(_hin * _spd, _vin * _spd);

        // the maze keeps changing until Susie's had enough
        if (state == "maze" || state == "cheater_talk")
        {
            var _sc = soul_cell();
            if (pending == undefined)
            {
                if (_sc[0] == goal_c && _sc[1] == goal_r)
                {
                    pending = build_next(_sc[0], _sc[1]); // made it — the Knight cheats
                    warn_timer = cheat_warn;
                }
                else if (t >= next_shuffle - shuffle_warn)
                {
                    pending = build_next(_sc[0], _sc[1]);
                    warn_timer = shuffle_warn;
                }
            }
            else
            {
                warn_timer--;
                if (warn_timer <= 0) swap_maze();
            }
        }
        if (!swords_started && state == "maze" && t >= swords_at) start_swords();
        if (!said_what && t >= what_at)
        {
            said_what = true;
            talk([ { speaker: obj_susie, text: "What the..." } ]);
        }

        if (state == "maze" && t >= cheater_at)
        {
            chain = talk([ { speaker: obj_susie, text: "You little cheater..." } ]);
            state = "cheater_talk";
        }
        else if (state == "cheater_talk" && !instance_exists(chain))
        {
            start_buster();
        }
        else if (state == "buster_windup")
        {
            if (!instance_exists(obj_susie) || obj_susie.image_index >= buster_fire_frame || obj_susie.image_speed == 0)
            {
                launch_buster();
            }
        }
        else if (state == "buster_fly")
        {
            array_insert(buster.trail, 0, { x: buster.x, y: buster.y, frame: buster.frame });
            if (array_length(buster.trail) > buster_trail_len) array_pop(buster.trail);

            buster.frame += buster_anim_speed;
            if (point_distance(buster.x, buster.y, buster.tx, buster.ty) <= buster_speed)
            {
                break_box();
            }
            else
            {
                buster.x += lengthdir_x(buster_speed, buster.dir);
                buster.y += lengthdir_y(buster_speed, buster.dir);
            }
        }
    break;

    // box is gone: the soul flies free, an arrow points it to Susie
    case "broken":
        arrow_timer++;
        if (!instance_exists(obj_soul)) { instance_destroy(); exit; }

        obj_soul.x = clamp(obj_soul.x + _hin * _spd, _v.x1 + free_margin, _v.x2 - free_margin);
        obj_soul.y = clamp(obj_soul.y + _vin * _spd, _v.y1 + free_margin, _v.y2 - free_margin);

        if (instance_exists(obj_susie)
            && point_in_rectangle(obj_soul.x, obj_soul.y, obj_susie.bbox_left, obj_susie.bbox_top, obj_susie.bbox_right, obj_susie.bbox_bottom))
        {
            if (absorb_sound != noone) audio_play_sound(absorb_sound, 1, false);

            flash_inst = instance_create_depth(0, 0, obj_susie.depth - 1, obj_heal_flash);
            flash_inst.target      = obj_susie.id;
            flash_inst.duration    = flash_frames;
            flash_inst.flash_color = c_white;
            state = "absorbing";
        }
    break;

    case "absorbing":
        // soul settles into the middle of Susie while she glows, then it's gone
        if (instance_exists(obj_soul) && obj_soul.visible && instance_exists(obj_susie))
        {
            var _cx = (obj_susie.bbox_left + obj_susie.bbox_right) / 2;
            var _cy = (obj_susie.bbox_top + obj_susie.bbox_bottom) / 2;
            obj_soul.x = lerp(obj_soul.x, _cx, 0.25);
            obj_soul.y = lerp(obj_soul.y, _cy, 0.25);
            if (point_distance(obj_soul.x, obj_soul.y, _cx, _cy) < 1) obj_soul.visible = false;
        }

        if (!instance_exists(flash_inst))
        {
            if (instance_exists(obj_soul)) obj_soul.visible = false; // taken in once the glow ends
            global.susie_soul = true; // her attacks do double damage from here on
                chain = talk([
                { run: function() { scr_set_battle_sprite(obj_susie, spr_susie_backlash, spr_susie_backlash, false); } },
                { speaker: obj_susie, text: "What the..." },
                { speaker: obj_susie, text: "..." },

                { run: function() { scr_set_battle_sprite(obj_susie, spr_susie_hurt, spr_susie_hurt, false); } },
                { speaker: obj_susie, text: "I..." },
                { speaker: obj_susie, text: "I feel..." },

                { run: function() { scr_set_battle_sprite(obj_susie, spr_susie_battle_idle_dark, spr_susie_battle_idle_dark, true); } },
                { speaker: obj_susie, text: "Like you're about to have a really $#&* time." },

                // back to normal once the line's done
                { run: function() { scr_set_battle_sprite(obj_susie, spr_susie_battle_idle, spr_susie_battle_idle, true); } }
            ]);
            state = "final_talk";
        }
    break;

    case "final_talk":
        if (!instance_exists(chain)) instance_destroy();
    break;
}