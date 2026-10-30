event_inherited();
if (!instance_exists(id) || !instance_exists(obj_battlebox)) exit;   // (attack 1's ended this frame)

// King's spades, one at a time, alternating sides, straight across the box at a random height. each one appears
// further out, glides in to just outside the box, sits there a moment (spade_wait) so you can see where it's coming from, then comes in
if (t < attack_duration - spade_stop - spade_wait - spade_approach_time)
{
    spade_timer--;
    if (spade_timer <= 0)
    {
        var _bb   = obj_battlebox;
        var _in   = scr_get_box_interior();
        var _side = next_side;
        next_side = -next_side;
        var _lx   = (_side == -1) ? (_in.x1 - spade_offset) : (_in.x2 + spade_offset);
        var _ly   = random_range(_in.y1 + 10, _in.y2 - 10);
        var _sx   = _lx + _side * spade_approach;   // where it first appears (further out on its side)
        var _w    = scr_box_local_to_world(_sx, _ly);

        var _s = instance_create_depth(_w.x, _w.y, _bb.depth - 1, obj_spadebullet);
        _s.lx           = _sx;
        _s.ly           = _ly;
        _s.dir          = -_side;
        _s.move_speed   = spade_speed;
        _s.damage       = spade_damage;
        _s.hit_radius   = spade_hit_radius;
        _s.image_xscale = spade_scale * _s.dir;   // the sprite points right
        _s.image_yscale = spade_scale;
        _s.image_angle  = _bb.box_angle;
        _s.travel_out   = spade_offset;
        _s.approach_to     = _lx;
        _s.approach_frames = spade_approach_time;
        _s.wait_frames  = spade_wait;
        _s.show_outside = true;
        audio_play_sound(snd_swing, 1, false, 0.5);

        spade_timer = irandom_range(spade_gap_min, spade_gap_max);
    }
}