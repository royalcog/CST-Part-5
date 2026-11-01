if (!instance_exists(body)) { instance_destroy(); exit; }

if (kind == "lancer")
{
    var _f  = hp / max_hp;
    var _dx = 0;
    if (hurt_t > 0)
    {
        // hit: his hurt sprite, shaking, less and less
        hurt_t--;
        _dx = ((hurt_t div 2) mod 2 == 0 ? 1 : -1) * hurt_shake * (hurt_t / hurt_len);
        if (hurt_t <= 0 && pre_hurt != undefined) { body.sprite_index = pre_hurt.spr; body.image_index = pre_hurt.img; pre_hurt = undefined; }
    }
    else if (_f < lancer_tremble_at && !instance_exists(obj_titan_attack3))   // (he stops once Susie snaps)
    {
        // low: trembling
        tremble_t++;
        _dx = ((tremble_t div lancer_tremble_every) mod 2 == 0 ? 1 : -1) * lancer_tremble_px;
    }
    body.shake_x = round(_dx);

    // standing in his battle sprite: which frame goes by how hurt he is
    if (body.sprite_index == spr_lancer_battle)
    {
        body.image_speed = 0;
        body.image_index = (_f > lancer_frame_at[0]) ? 0 : ((_f > lancer_frame_at[1]) ? 1 : 2);
    }
}
else if (hurt_t > 0) hurt_t--;

// the Titan pulses white while the cursor's on it (it draws that itself: it's made of layers)
if (kind == "titan") body.target_flash = targeted;

follow();