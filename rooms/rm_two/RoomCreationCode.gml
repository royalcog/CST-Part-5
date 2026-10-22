with (obj_kris)
{
    face = RIGHT;
    image_speed = 0;
}

// Part 5: the room as Part 4 left it, with the Titan's tower standing over where the fountain was
if (!layer_exists("Titan")) layer_create(345, "Titan");
if (!instance_exists(obj_shadow_tint)) instance_create_depth(0, 0, 0, obj_shadow_tint);
if (!instance_exists(obj_titan_tower)) instance_create_layer(0, 0, "Titan", obj_titan_tower);
if (!instance_exists(obj_rm_two_p5))   instance_create_depth(0, 0, -2050, obj_rm_two_p5);