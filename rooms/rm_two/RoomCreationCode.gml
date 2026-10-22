with (obj_kris)
{
    face = RIGHT;
    image_speed = 0;
}

// the fountain gets its own layer, behind the floor tiles (300) and in front of the background (400)
if (!layer_exists("Fountain")) layer_create(350, "Fountain");
if (!instance_exists(obj_dark_fountain)) instance_create_layer(room_width / 2, 364, "Fountain", obj_dark_fountain);

if (!instance_exists(obj_shadow_tint))  instance_create_depth(0, 0, 0, obj_shadow_tint);
if (!instance_exists(obj_rm_two_scene)) instance_create_depth(0, 0, -3500, obj_rm_two_scene);