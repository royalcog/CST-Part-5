if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
if (obj_battlebox.state == "closing") fading_out = true;

if (fading_out)
{
    image_alpha -= 1 / fade_frames;
    if (image_alpha <= 0) { instance_destroy(); exit; }
}
else
{
    image_alpha = min(image_alpha + 1 / fade_frames, 1);
}

if (aim_frames > 0)
{
    aim_frames--;

    if (aim_frames > lock_frames && instance_exists(obj_soul))
    {
        move_dir = point_direction(x, y, obj_soul.x, obj_soul.y);
    }
    image_angle += angle_difference(move_dir, image_angle) * aim_turn;
    image_blend = (aim_frames < blink_frames && (aim_frames div 4) mod 2 == 0) ? c_red : c_white;

    if (aim_frames <= 0)
    {
        image_angle = move_dir;
        image_blend = c_white;
        if (fire_sound != -1) audio_play_sound(fire_sound, 5, false, fire_gain);
    }
}
else
{
    move_speed = min(move_speed + accel, max_speed);
    x += lengthdir_x(move_speed, move_dir);
    y += lengthdir_y(move_speed, move_dir);
    image_angle = move_dir;
}

// only dangerous once fully faded in, never while fading out
if (!fading_out && image_alpha >= 1
 && instance_exists(obj_soul) && !obj_soul.invulnerable
 && point_distance(x, y, obj_soul.x, obj_soul.y) <= hit_radius)
{
    scr_soul_take_hit(damage, c_white, c_white);
    instance_destroy();
    exit;
}

var _in = scr_get_box_interior();
var _l  = scr_world_to_box_local(x, y); // box's own frame, so this still works while the box is tilted
if (_l.x >= _in.x1 && _l.x <= _in.x2 && _l.y >= _in.y1 && _l.y <= _in.y2)
{
    entered = true;
}
else if (entered && (_l.x < _in.x1 - exit_margin || _l.x > _in.x2 + exit_margin || _l.y < _in.y1 - exit_margin || _l.y > _in.y2 + exit_margin))
{
    instance_destroy();
    exit;
}

life--;
if (life <= 0) instance_destroy();