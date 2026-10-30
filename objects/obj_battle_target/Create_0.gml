// a battle enemy that's really another object standing in the room: King (obj_king), Lancer (obj_lancer) or the
// Titan (obj_titan_reveal). obj_battle_menu treats it exactly like a Titan Spawn (name, HP, MERCY, take_hit...),
// and this passes the hits / the targeting flash on to whatever it's standing in for.
// made with scr_battle_target_make (scr_titan_battle) right before the menu.
// x/y = a spot just above the body's middle (where Rude Buster aims and damage numbers pop up), kept up to date in Step
sprite_index = spr_pixel_white;   // invisible: it only needs a sprite so the menu's maths (yoffset, facing) works
visible      = true;              // (Draw only draws the targeting flash over the body, never itself)

// --- set right after making it ---
body        = noone;     // the instance it stands in for
kind        = "";        // "king" / "lancer" / "titan": how it reacts to being hit and targeted
side        = -1;        // which way the party faces to hit it: -1 left, 1 right
aim_dx      = 0;         // fine-tunes x/y (room px) from the body's middle
aim_dy      = 0;

// --- as an enemy (the same fields obj_battle_titanspawn has) ---
enemy_name      = "";
max_hp          = 1000;
hp              = max_hp;
at              = 10;
df              = 0;
rudebuster_mult = 1;
can_spare       = false;
no_mercy_text   = "* ...it can't be SPARED.";
mercy           = 0;
tired_at        = 0.35;
check_text      = "";
can_be_defeated = false;  // false: its HP stops at 1 (this fight can't be won by beating it down)
targeted        = false;
gone            = false;
spared          = false;
home_y          = 0;      // the order it's listed in (top to bottom); obj_battle_menu sorts by this
line_broken     = false;  // its row in the target list got smashed: it can't be picked any more

hurt_t     = 0;           // frames left of its hurt reaction
hurt_len   = 24;
hurt_shake = 4;           // px (Lancer, who has no hurt sprite: he just shakes)
shake_base = undefined;

is_tired = function() { return can_spare && !gone && hp <= max_hp * tired_at; }
is_alive = function() { return !gone; }

/// the menu hits it: damage number (in the attacker's colour), its hurt reaction
take_hit = function(_amount, _col)
{
    if (gone) return noone;
    hp = can_be_defeated ? max(0, hp - _amount) : max(1, hp - _amount);
    if (instance_exists(obj_battle_menu)) obj_battle_menu.play_once(snd_damagetaken);
    else audio_play_sound(snd_damagetaken, 1, false);
    hurt_t = hurt_len;

    switch (kind)
    {
        case "king":
            // obj_king's own hurt flash: spr_king_hurt, then back to whatever he was doing (same origin as his battle idle)
            with (body)
            {
                if (hurt_timer <= 0)
                {
                    pre_hurt_sprite      = sprite_index;
                    pre_hurt_image_index = image_index;
                    pre_hurt_image_speed = image_speed;
                }
                sprite_index = spr_king_hurt;
                image_index  = 0;
                image_speed  = 0;
                hurt_timer   = hurt_duration;
            }
        break;
        case "lancer":
            if (instance_exists(body) && shake_base == undefined) shake_base = body.x;
        break;
        case "titan":
            if (instance_exists(body)) body.hurt_red = 1;
        break;
    }

    var _p = scr_trigger_damage_popup(id, _amount, _col, _col, 0, -24, noone);
    if (hp <= 0) { gone = true; }
    return _p;
}

/// (it can't be spared, but the menu calls this the same way it would for a Titan Spawn)
spare = function() { }

/// follows the body around
follow = function()
{
    if (!instance_exists(body)) return;
    var _b = body;
    if (kind == "titan")
    {
        // the Titan's drawn from its top-left corner, mostly off the right of the screen: aim at its chest
        x = _b.x + 330 + aim_dx;
        y = _b.y + 230 + aim_dy;
    }
    else
    {
        var _l = sprite_get_bbox_left(_b.sprite_index), _r = sprite_get_bbox_right(_b.sprite_index) + 1;
        var _t = sprite_get_bbox_top(_b.sprite_index);
        x = _b.x + ((_l + _r) / 2 - sprite_get_xoffset(_b.sprite_index)) * _b.image_xscale + aim_dx;
        y = _b.y + (_t - sprite_get_yoffset(_b.sprite_index)) * _b.image_yscale + 30 + aim_dy;
    }
    depth = _b.depth - 1;
}