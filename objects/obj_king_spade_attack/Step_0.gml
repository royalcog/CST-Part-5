if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
var _bb = obj_battlebox;

switch (state)
{
    case "spawning":
        attack_timer++;

        spin_speed = min(spin_speed + spin_speed_max / spin_ramp_frames, spin_speed_max);
        _bb.box_angle += spin_speed * spin_dir;

        if (attack_timer >= start_delay + attack_duration)
        {
            // ease to the next quarter-turn in the spin direction (box is square, so any 90 looks like 0)
            unspin_from = _bb.box_angle;
            unspin_to = (spin_dir > 0) ? ceil(_bb.box_angle / 90) * 90 : floor(_bb.box_angle / 90) * 90;
            // length chosen so it starts at roughly the current spin speed, then slows to a stop
            unspin_frames = clamp(2 * abs(unspin_to - unspin_from) / max(spin_speed, 0.01), 20, 120);
            unspin_timer = 0;
            state = "unspin";
            break;
        }

        timer--;
        if (timer <= 0)
        {
            // everything here is in the box's own (unrotated) frame
            var _in = scr_get_box_interior();
            var _side = choose(-1, 1); // -1 = enters from the left, 1 = enters from the right

            var _lx = (_side == -1) ? (_in.x1 - spade_spawn_offset) : (_in.x2 + spade_spawn_offset);
            var _ly = random_range(_in.y1 + 6, _in.y2 - 6);
            var _w  = scr_box_local_to_world(_lx, _ly);

            var _s = instance_create_depth(_w.x, _w.y, _bb.depth - 1, obj_spadebullet);
            _s.lx           = _lx;
            _s.ly           = _ly;
            _s.dir          = -_side; // travels toward the opposite side
            _s.move_speed   = spade_speed;
            _s.damage       = spade_damage;
            _s.hit_radius   = spade_hit_radius;
            _s.image_xscale = spade_scale * _s.dir; // sprite points right, so flip it for right-side spades
            _s.image_yscale = spade_scale;
            _s.image_angle  = _bb.box_angle;
            _s.travel_out   = spade_spawn_offset;

            timer = irandom_range(spawn_gap_min, spawn_gap_max);
        }
    break;

    // spades already in flight keep going while the box settles; then the box closes
    case "unspin":
        unspin_timer++;
        var _t = clamp(unspin_timer / unspin_frames, 0, 1);
        _t = 1 - sqr(1 - _t); // ease-out
        _bb.box_angle = lerp(unspin_from, unspin_to, _t);

        if (_t >= 1)
        {
            _bb.box_angle = 0;
            instance_destroy();
        }
    break;
}