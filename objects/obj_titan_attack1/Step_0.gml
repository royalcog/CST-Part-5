event_inherited();
if (!instance_exists(id) || !instance_exists(obj_battlebox)) exit;   // (attack 1's ended this frame)

// King's spades, one at a time, straight across the box at a random height (each side picked at random)
if (t < attack_duration - spade_stop)
{
    spade_timer--;
    if (spade_timer <= 0)
    {
        var _bb   = obj_battlebox;
        var _in   = scr_get_box_interior();
        var _side = choose(-1, 1);   // -1: in from the left, 1: in from the right
        var _lx   = (_side == -1) ? (_in.x1 - spade_offset) : (_in.x2 + spade_offset);
        var _ly   = random_range(_in.y1 + 6, _in.y2 - 6);
        var _w    = scr_box_local_to_world(_lx, _ly);

        var _s = instance_create_depth(_w.x, _w.y, _bb.depth - 1, obj_spadebullet);
        _s.lx           = _lx;
        _s.ly           = _ly;
        _s.dir          = -_side;
        _s.move_speed   = spade_speed;
        _s.damage       = spade_damage;
        _s.hit_radius   = spade_hit_radius;
        _s.image_xscale = spade_scale * _s.dir;   // the sprite points right
        _s.image_yscale = spade_scale;
        _s.image_angle  = _bb.box_angle;
        _s.travel_out   = spade_offset;
        audio_play_sound(snd_swing, 1, false, 0.5);

        spade_timer = irandom_range(spade_gap_min, spade_gap_max);
    }
}