if (!enabled) exit;
if (instance_exists(obj_plat_controller) && obj_plat_controller.wrap_on) exit;   // the climb draws it itself (bent round the tower)
draw_clear(c_black);
draw_surface(application_surface, ox, oy);