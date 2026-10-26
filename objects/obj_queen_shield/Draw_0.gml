var _h  = sprite_get_height(spr_queen_shield) * scale;
var _top = y - _h + ((state == "shatter") ? 0 : sin(bob) * bob_amp);   // floating, bobbing

switch (state)
{
    case "build":
    case "down":
    {
        // the real shield, in bands from the bottom up: each one drops onto the one below and settles,
        // so it always reads as one wall going up (taking it down: top band first, lifting off and fading)
        var _sh   = sprite_get_height(spr_queen_shield);
        var _band = ceil(_sh / sections);
        for (var k = 0; k < sections; k++)                 // k = 0 is the bottom band
        {
            var _sy = max(0, _sh - (k + 1) * _band);
            var _hh = (_sh - k * _band) - _sy;
            if (_hh <= 0) continue;
            var _a, _dy;
            if (state == "build")
            {
                var _kt = clamp((t - k * section_every) / section_every, 0, 1);
                if (_kt <= 0) continue;
                _kt = 1 - power(1 - _kt, 2);
                _a = _kt; _dy = -section_drop * (1 - _kt);
            }
            else
            {
                var _kt = clamp((t - (sections - 1 - k) * 2) / 6, 0, 1);
                if (_kt >= 1) continue;
                _a = 1 - _kt; _dy = -section_drop * _kt;
            }
            draw_band(0, _sy, _hh, _top, _dy, _a);
        }
    }
    break;
    case "up":
        draw_part(spr_queen_shield, hp_frame(), 0, _top, 1);
        if (flash > 0)
        {
            gpu_set_fog(true, c_white, 0, 0);
            draw_part(spr_queen_shield, hp_frame(), 0, _top, flash);
            gpu_set_fog(false, c_white, 0, 0);
        }
    break;

    case "crack":   // the cracked frames, shaking
        draw_part(spr_queen_shield, (hp_frame() == 0) ? 2 : 3, random_range(-2, 2), _top, 1);
    break;

    case "shatter":
        for (var i = 0; i < array_length(shards); i++)
        {
            var _s = shards[i];
            draw_part(spr_queen_shield_break, _s.f, _s.x, _top + _s.y, _s.a);
        }
    break;
}