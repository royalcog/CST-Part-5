var _v = view_rect();

// maze
if (maze != undefined && cols > 0)
{
    var _blink = ((warn_timer div 6) mod 2 == 0);
    draw_set_color(wall_color);
    for (var i = 0; i < cols; i++)
    for (var j = 0; j < rows; j++)
    {
        if (i < cols - 1) draw_wall(maze.v[i][j], (pending != undefined) ? pending.m.v[i][j] : maze.v[i][j], vrect(i, j), _blink);
        if (j < rows - 1) draw_wall(maze.h[i][j], (pending != undefined) ? pending.m.h[i][j] : maze.h[i][j], hrect(i, j), _blink);
    }

    // the goal
    var _gx = ox + (goal_c + 0.5) * cw;
    var _gy = oy + (goal_r + 0.5) * ch;
    var _gs = min(cw, ch) * (0.22 + 0.05 * sin(current_time / 150));
    draw_set_color(goal_color);
    draw_set_alpha(wall_alpha);
    draw_rectangle(_gx - _gs, _gy - _gs, _gx + _gs, _gy + _gs, true);
    draw_rectangle(_gx - _gs * 0.4, _gy - _gs * 0.4, _gx + _gs * 0.4, _gy + _gs * 0.4, false);
}

// rude buster
if (buster != undefined)
{
    var _n = array_length(buster.trail);
    gpu_set_blendmode(bm_add);
    for (var j = _n - 1; j >= 0; j--)
    {
        var _tr = buster.trail[j];
        draw_sprite_ext(buster_projectile, _tr.frame, _tr.x, _tr.y, buster_scale, buster_scale, buster.dir, c_white,
            0.35 * (1 - (j + 1) / (_n + 1)));
    }
    gpu_set_blendmode(bm_normal);
    draw_sprite_ext(buster_projectile, buster.frame, buster.x, buster.y, buster_scale, buster_scale, buster.dir, c_white, 1);
}

// falling pieces
for (var i = 0; i < array_length(debris); i++)
{
    var _d = debris[i];
    if (_d.kind == "box")
    {
        draw_sprite_general(_d.spr, _d.img, _d.l, _d.t, _d.w, _d.h, _d.x, _d.y, _d.xs, _d.ys, _d.rot,
            c_white, c_white, c_white, c_white, 1);
    }
    else
    {
        draw_rot_rect(_d.x, _d.y, _d.w, _d.h, _d.rot, wall_color, 1);
    }
}

// arrow pointing the soul to Susie, blinking
if (state == "broken" && instance_exists(obj_soul) && instance_exists(obj_susie) && (arrow_timer div arrow_blink) mod 2 == 0)
{
    var _tx  = (obj_susie.bbox_left + obj_susie.bbox_right) / 2;
    var _ty  = (obj_susie.bbox_top + obj_susie.bbox_bottom) / 2;
    var _dir = point_direction(obj_soul.x, obj_soul.y, _tx, _ty);
    var _ax  = obj_soul.x + lengthdir_x(arrow_dist, _dir);
    var _ay  = obj_soul.y + lengthdir_y(arrow_dist, _dir);
    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_triangle(
        _ax + lengthdir_x(arrow_size, _dir),             _ay + lengthdir_y(arrow_size, _dir),
        _ax + lengthdir_x(arrow_size * 0.7, _dir + 140), _ay + lengthdir_y(arrow_size * 0.7, _dir + 140),
        _ax + lengthdir_x(arrow_size * 0.7, _dir - 140), _ay + lengthdir_y(arrow_size * 0.7, _dir - 140),
        false);
}

// white flash when the box breaks
if (break_flash > 0)
{
    draw_set_color(c_white);
    draw_set_alpha(break_flash * 0.8);
    draw_rectangle(_v.x1, _v.y1, _v.x2, _v.y2, false);
}

draw_set_alpha(1);
draw_set_color(c_white);