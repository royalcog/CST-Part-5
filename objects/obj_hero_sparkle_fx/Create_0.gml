target = noone; // set right after instance_create — the hero to sparkle around
life = 144;      // ~2.4s, matches snd_sparklegem's length
timer = 0;
spawn_interval = 8;
spawn_timer = 0;

psystem = part_system_create();
part_system_depth(psystem, -100);

ptype = part_type_create();
part_type_shape(ptype, pt_shape_star);
part_type_size(ptype, 0.12, 0.25, 0, 0);  // much smaller
part_type_colour2(ptype, c_white, c_yellow);
part_type_alpha3(ptype, 0, 1, 0);
part_type_speed(ptype, 0.15, 0.5, 0, 0.03);
part_type_direction(ptype, 0, 360, 0, 0);
part_type_gravity(ptype, 0.01, 270);
part_type_life(ptype, 25, 40);
part_type_blend(ptype, true);