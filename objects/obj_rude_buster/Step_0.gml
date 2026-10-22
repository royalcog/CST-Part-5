var _v = view_rect();

for (var i = array_length(debris) - 1; i >= 0; i--)
{
    var _d = debris[i];
    _d.vy  += debris_gravity;
    _d.x   += _d.vx;
    _d.y   += _d.vy;
    _d.rot += _d.vr;
    if (_d.y > _v.y2 + 200) array_delete(debris, i, 1);
}
flash = max(flash - 0.05, 0);

// Susie back to idle once the whole swing has played
if (!susie_done)
{
    if (!instance_exists(obj_susie) || obj_susie.sprite_index != susie_sprite)
    {
        susie_done = true;
    }
    else if (obj_susie.image_speed == 0)
    {
        with (obj_susie)
        {
            sprite_index = spr_susie_battle_idle;
            last_sprite  = sprite_index;
            image_index  = 0;
            image_speed  = 1;
            anim_loop    = true;
        }
        susie_done = true;
    }
}

switch (state)
{
    case "windup":
        if (!instance_exists(obj_susie) || obj_susie.image_index >= fire_frame || obj_susie.image_speed == 0) launch();
    break;

    case "fly":
        array_insert(proj.trail, 0, { x: proj.x, y: proj.y, frame: proj.frame });
        if (array_length(proj.trail) > trail_len) array_pop(proj.trail);
        proj.frame += proj_anim_speed;

        if (point_distance(proj.x, proj.y, proj.tx, proj.ty) <= proj_speed)
        {
            if (break_on_hit) break_box();
            else
            {
                landed = true;
                proj = undefined;
                state = "broken"; // nothing broke, it just cleans itself up once Susie's done
            }
        }
        else
        {
            proj.x += lengthdir_x(proj_speed, proj.dir);
            proj.y += lengthdir_y(proj_speed, proj.dir);
        }
    break;

    case "broken":
        if (array_length(debris) == 0 && susie_done && flash <= 0) instance_destroy();
    break;
}