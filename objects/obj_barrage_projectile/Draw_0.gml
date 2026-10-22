draw_self();
if (global.DEBUG_BARRAGE)
{
    draw_set_color(c_red);
    draw_circle(x, y, 3, false);
    draw_circle(x, y, hit_radius, true);
    if (instance_exists(target_inst))
    {
        var _hp = scr_get_hit_point(target_inst);
        draw_set_color(c_lime);
        draw_circle(_hp.x, _hp.y, 4, false);
        draw_line(target_inst.x, target_inst.y, _hp.x, _hp.y);
    }
    draw_set_color(c_white);
}