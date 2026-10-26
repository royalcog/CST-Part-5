var _h  = sprite_get_height(spr_queen_shield) * scale;
var _top = y - _h + ((state == "shatter") ? 0 : sin(bob) * bob_amp);   // floating, bobbing

switch (state)
{
    case "build":
    case "down":
    {
        // the sections, stacked bottom to top (each one's a diagonal slab: spr_queen_shield_pieces)
        var _ph   = sprite_get_height(spr_queen_shield_pieces) * scale;
        var _step = (_h - _ph) / max(1, sections - 1);
        for (var k = 0; k < sections; k++)
        {
            var _order = sections - 1 - k;          // the bottom one (k = sections - 1) comes first
            var _a, _dy;
            if (state == "build")
            {
                var _kt = clamp((t - _order * section_every) / section_every, 0, 1);
                if (_kt <= 0) continue;
                _a = _kt; _dy = -section_drop * (1 - _kt);
            }
            else
            {
                var _kt = clamp((t - k * 2) / 6, 0, 1);   // the top one goes first
                if (_kt >= 1) continue;
                _a = 1 - _kt; _dy = section_drop * _kt;
            }
            var _spr = (k mod 2 == 0) ? spr_queen_shield_pieces : spr_queen_shield_pieces_1;
            draw_part(_spr, k mod sprite_get_number(_spr), 0, _top + k * _step + _dy, _a);
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