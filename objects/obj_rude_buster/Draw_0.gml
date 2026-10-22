var _v = view_rect();

if (proj != undefined)
{
    var _n = array_length(proj.trail);
    gpu_set_blendmode(bm_add);
    for (var j = _n - 1; j >= 0; j--)
    {
        var _tr = proj.trail[j];
        draw_sprite_ext(projectile, _tr.frame, _tr.x, _tr.y, proj_scale, proj_scale, proj.dir, c_white, 0.35 * (1 - (j + 1) / (_n + 1)));
    }
    gpu_set_blendmode(bm_normal);
    draw_sprite_ext(projectile, proj.frame, proj.x, proj.y, proj_scale, proj_scale, proj.dir, c_white, 1);
}

for (var i = 0; i < array_length(debris); i++)
{
    var _d = debris[i];
    draw_sprite_general(_d.spr, _d.img, _d.l, _d.t, _d.w, _d.h, _d.x, _d.y, _d.xs, _d.ys, _d.rot,
        c_white, c_white, c_white, c_white, 1);
}

if (flash > 0)
{
    draw_set_color(c_white);
    draw_set_alpha(flash * 0.8);
    draw_rectangle(_v.x1, _v.y1, _v.x2, _v.y2, false);
    draw_set_alpha(1);
}