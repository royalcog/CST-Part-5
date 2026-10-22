// --- tuning ---
// each wave: how many bombs, frames between tosses, and whether bombs after the first land near it
waves = [
    { bombs: 1, gap: 0,  cluster: false },
    { bombs: 2, gap: 20, cluster: false },
    { bombs: 3, gap: 15, cluster: false },
    { bombs: 4, gap: 12, cluster: true  },  // close together so the rings overlap
    { bombs: 5, gap: 10, cluster: false },
    { bombs: 5, gap: 8,  cluster: false }
];
fuse_start     = 80;  // fuse length on the first wave...
fuse_end       = 60;  // ...shortening a little each wave down to this on the last
box_scale      = 0.85; // box shrinks to this before the first toss
wave_pause     = 35;  // after a wave's bombs have all burst, before the next wave
start_delay    = 20;  // beat after the box finishes shrinking, before the first toss
end_delay      = 25;  // after the last burst, before the box closes (ring spades still flying)
land_margin    = 28;  // bombs land at least this far from the walls
bomb_spacing   = 40;  // non-cluster bombs land at least this far from each other
cluster_radius = 60;  // how close clustered bombs land to the first one
toss_offset_x  = -30; // where the toss starts, relative to King
toss_offset_y  = -80;
toss_sound     = snd_bombfall; // -1 for none

// --- state ---
wave_index = 0;
tossed     = 0;
timer      = start_delay;
state      = "shrink";
cluster_x  = 0;
cluster_y  = 0;

obj_battlebox.target_scale_x = box_scale;
obj_battlebox.target_scale_y = box_scale;

with (obj_box_bullet_drawer) instance_destroy(); // clear any leftover
instance_create_depth(0, 0, obj_battlebox.depth - 1, obj_box_bullet_drawer);

toss_bomb = function(_near_first, _fuse)
{
    var _in = scr_get_box_interior();
    var _lx, _ly;

    if (_near_first)
    {
        _lx = clamp(cluster_x + random_range(-cluster_radius, cluster_radius), _in.x1 + land_margin, _in.x2 - land_margin);
        _ly = clamp(cluster_y + random_range(-cluster_radius, cluster_radius), _in.y1 + land_margin, _in.y2 - land_margin);
    }
    else
    {
        // try a few spots and keep the first one that isn't crowding a bomb already out there
        for (var _try = 0; _try < 12; _try++)
        {
            _lx = random_range(_in.x1 + land_margin, _in.x2 - land_margin);
            _ly = random_range(_in.y1 + land_margin, _in.y2 - land_margin);

            var _clear = true;
            with (obj_spade_bomb)
            {
                if (point_distance(land_x, land_y, _lx, _ly) < other.bomb_spacing) { _clear = false; break; }
            }
            if (_clear) break;
        }
        cluster_x = _lx;
        cluster_y = _ly;
    }

    var _sx = instance_exists(obj_king) ? obj_king.x + toss_offset_x : _in.x2 + 200;
    var _sy = instance_exists(obj_king) ? obj_king.y + toss_offset_y : _in.y1 - 100;

    var _b = instance_create_depth(_sx, _sy, obj_battlebox.depth - 1, obj_spade_bomb);
    _b.start_x     = _sx;
    _b.start_y     = _sy;
    _b.land_x      = _lx;
    _b.land_y      = _ly;
    _b.fuse_frames = _fuse;

    if (toss_sound != -1) audio_play_sound(toss_sound, 5, false);
};