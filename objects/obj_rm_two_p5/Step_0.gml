t++;

switch (state)
{
    case "setup":
    {
        // Susie & Ralsei, still looking up at the tower
        var _s = instance_exists(obj_susie)  ? instance_find(obj_susie, 0)  : instance_create_layer(0, 0, "Instances", obj_susie);
        var _r = instance_exists(obj_ralsei) ? instance_find(obj_ralsei, 0) : instance_create_layer(0, 0, "Instances", obj_ralsei);
        var _pair = [ [_s, spr_susie_walk_up, susie_x], [_r, spr_ralsei_walk_up, ralsei_x] ];
        for (var i = 0; i < 2; i++)
        {
            var _o = _pair[i][0];
            _o.sprite_index = _pair[i][1];
            _o.last_sprite  = _o.sprite_index;   // placed by hand, so scr_auto_keep_feet leaves it alone
            _o.image_index  = 0;
            _o.image_speed  = 0;
            _o.anim_loop    = true;
            _o.image_alpha  = 1;
            _o.visible      = true;
            set_feet(_o, _pair[i][2], stand_y);
        }
        state = "intro";
        t = 0;
    }
    break;

    case "intro":
        // wait out the room's fade-in, then a beat
        if (instance_exists(obj_cutscenefade)) t = 0;
        if (t >= intro_wait && instance_exists(obj_cutscenehandler_midfightattacks))
        {
            lancer_enter();
            state = "talk";
        }
    break;

    case "feather_turn":
        if (t >= susie_turn_wait)
        {
            face(obj_susie, susie_hold_sprite);
            feather.on = true;
            feather.t  = 0;
            if (feather_sound != noone) audio_play_sound(feather_sound, 1, false);
            state = "feather";
            t = 0;
        }
    break;

    case "feather":
        if (t == feather_hold) white_warp();
    break;
}

// the feather, over Susie's fist
if (feather.on && instance_exists(obj_susie))
{
    feather.t++;
    var _s  = obj_susie;
    var _fx = _s.x + (feather_fist.x - sprite_get_xoffset(_s.sprite_index)) * _s.image_xscale;
    var _fy = _s.y + (feather_fist.y - sprite_get_yoffset(_s.sprite_index)) * _s.image_yscale;
    var _k  = clamp(feather.t / feather_rise, 0, 1);
    _k = 1 - power(1 - _k, 3);
    feather.alpha = _k;
    feather.x = _fx;
    feather.y = _fy - (sprite_get_height(feather_sprite) / 2) * feather_scale + 4 - feather_lift * _k;

    if (feather.t mod twinkle_every == 1)
        array_push(twinkles, { x: feather.x + random_range(-22, 22), y: feather.y + random_range(-22, 16), t: 0, life: 20, sz: random_range(4, 7) });
}
for (var i = array_length(twinkles) - 1; i >= 0; i--)
    if (++twinkles[i].t >= twinkles[i].life) array_delete(twinkles, i, 1);