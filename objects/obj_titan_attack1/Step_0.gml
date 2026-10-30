event_inherited();
if (!instance_exists(id) || !instance_exists(obj_battlebox)) exit;   // (attack 1's ended this frame)

// King's spades, one at a time, straight across the box at a random height (each side picked at random).
// its lane flashes first (warn_time), then it comes in
if (t < attack_duration - spade_stop - warn_time)
{
    spade_timer--;
    if (spade_timer <= 0)
    {
        var _in = scr_get_box_interior();
        array_push(warnings, { side: choose(-1, 1), ly: random_range(_in.y1 + 10, _in.y2 - 10), t: 0 });
        spade_timer = irandom_range(spade_gap_min, spade_gap_max);
    }
}
for (var i = array_length(warnings) - 1; i >= 0; i--)
{
    var _wn = warnings[i];
    _wn.t++;
    if (_wn.t < warn_time) continue;

    var _bb   = obj_battlebox;
    var _in   = scr_get_box_interior();
    var _side = _wn.side;   // -1: in from the left, 1: in from the right
    var _lx   = (_side == -1) ? (_in.x1 - spade_offset) : (_in.x2 + spade_offset);
    var _w    = scr_box_local_to_world(_lx, _wn.ly);

    var _s = instance_create_depth(_w.x, _w.y, _bb.depth - 1, obj_spadebullet);
    _s.lx           = _lx;
    _s.ly           = _wn.ly;
    _s.dir          = -_side;
    _s.move_speed   = spade_speed;
    _s.damage       = spade_damage;
    _s.hit_radius   = spade_hit_radius;
    _s.image_xscale = spade_scale * _s.dir;   // the sprite points right
    _s.image_yscale = spade_scale;
    _s.image_angle  = _bb.box_angle;
    _s.travel_out   = spade_offset;
    audio_play_sound(snd_swing, 1, false, 0.5);
    array_delete(warnings, i, 1);
}