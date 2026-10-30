if (!instance_exists(body)) { instance_destroy(); exit; }

if (hurt_t > 0)
{
    hurt_t--;
    // Lancer has no hurt sprite: he shakes, less and less
    if (kind == "lancer" && shake_base != undefined)
    {
        body.x = shake_base + ((hurt_t div 2) mod 2 == 0 ? 1 : -1) * hurt_shake * (hurt_t / hurt_len);
        if (hurt_t <= 0) { body.x = shake_base; shake_base = undefined; }
    }
}

// the Titan pulses white while the cursor's on it (it draws that itself: it's made of layers)
if (kind == "titan") body.target_flash = targeted;

follow();