lights = [];

with (obj_light_source)
{
    if (light_on)
    {
        var _lx = x + light_offset_x;
        var _ly = y + light_offset_y;
        var _pulse = sin(current_time / 300) * 8;
        array_push(other.lights, {
            x: _lx - 12,
            y: _ly,
            radius: light_radius + _pulse,
            strength: light_strength
        });
    }
}

// Smoothly transition alpha toward targets
darkness_alpha_left = lerp(darkness_alpha_left, darkness_target_left, darkness_lerp_speed);
darkness_alpha_right = lerp(darkness_alpha_right, darkness_target_right, darkness_lerp_speed);