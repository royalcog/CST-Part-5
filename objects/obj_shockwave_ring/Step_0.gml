switch (phase)
{
    case "telegraph":
        telegraph_timer--;
        if (telegraph_timer <= 0)
        {
            phase = "expanding";
        }
    break;

    case "expanding":
        radius += grow_speed;

        if (!already_hit && instance_exists(obj_soul))
        {
            var _dist = point_distance(center_x, center_y, obj_soul.x, obj_soul.y);
            if (radius >= _dist)
            {
                already_hit = true;

                var _soul_quadrant = "";
                if (obj_soul.x < center_x)
                {
                    _soul_quadrant = (obj_soul.y < center_y) ? "tl" : "bl";
                }
                else
                {
                    _soul_quadrant = (obj_soul.y < center_y) ? "tr" : "br";
                }

                if (_soul_quadrant != safe_quadrant)
                {
                    scr_soul_take_hit(0, obj_mewmew.damage_color, obj_mewmew.damage_color);
                }
            }
        }

        if (radius >= max_radius)
        {
            instance_destroy();
        }
    break;
}