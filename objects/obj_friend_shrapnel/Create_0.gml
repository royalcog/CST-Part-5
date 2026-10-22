if (!variable_instance_exists(id, "move_dir")) move_dir = 0;
if (!variable_instance_exists(id, "move_speed")) move_speed = 4;
if (!variable_instance_exists(id, "lifespan")) lifespan = 45;
if (!variable_instance_exists(id, "spin_speed")) spin_speed = 6; // degrees/frame the trajectory curves — gives the burst a rotating, pinwheel-ish look
if (!variable_instance_exists(id, "shrapnel_color")) shrapnel_color = c_yellow;
if (!variable_instance_exists(id, "shrapnel_radius")) shrapnel_radius = 4;

timer = 0;
sprite_index = -1;
depth = -375;