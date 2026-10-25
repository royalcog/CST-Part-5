// Part 5: the top of the Titan's tower, back to top-down.
// (paint the floor on a tile layer under "Instances"; the room's just black until then)
with (obj_kris)
{
    face = RIGHT;
    image_speed = 0;
}

if (!instance_exists(obj_tower_top_scene)) instance_create_depth(0, 0, -2050, obj_tower_top_scene);