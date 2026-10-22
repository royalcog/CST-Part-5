// the tower climb

// the Titan's tower behind everything (in front of the Background layer at 500, behind the tiles)
if (!layer_exists("TowerBG")) layer_create(450, "TowerBG");
if (!instance_exists(obj_titan_tower))
{
    with (instance_create_layer(0, 0, "TowerBG", obj_titan_tower))
    {
        base_bottom_y = room_height;   // its base at the bottom of the room
        pillar_w      = 480;           // px wide (rm_two's is 274)
        parallax      = 0.5;           // 1 = moves with the room, smaller = feels further back
        tower_shade   = 0.6;
    }
}

if (!instance_exists(obj_plat_controller)) instance_create_depth(0, 0, 0, obj_plat_controller);