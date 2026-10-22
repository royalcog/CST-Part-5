if (emitter_alpha <= 0) exit;

var _pulse = (state == "windup") ? 1 + 0.15 * sin(timer * 0.3) : 1;
var _blend = (state == "windup" && (timer div 5) mod 2 == 0) ? c_red : c_white;
var _s = emitter_scale * _pulse;

draw_sprite_ext(spr_spade, 0, round(cx), round(cy), _s, _s, base_angle, _blend, emitter_alpha);