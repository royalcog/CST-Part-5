t++;

switch (state)
{
    case "setup":
    {
        // Queen & Lancer, still looking up at the Titan. Susie & Ralsei below the screen
        place(obj_queen,  spr_queen_walk_up,  queen_x,  queen_y);
        place(obj_lancer, spr_lancer_up,      lancer_x, lancer_y);
        place(obj_susie,  susie_up,  susie_x,  pair_from_y);
        place(obj_ralsei, ralsei_up, ralsei_x, pair_from_y);

        // the chair, parked and empty
        chair = instance_create_depth(chair_x, chair_y, -2300, obj_queen_chair);
        chair.sprite_index = spr_queen_chair;
        if (chair_flip) chair.image_xscale = -2;
        chair.home_y = chair_y;
        chair.from_y = chair_y;
        chair.base_y = chair_y;
        chair.state  = "hover";

        state = "intro";
        t = 0;
    }
    break;

    case "intro":
        // wait out the room's fade-in, then a beat
        if (instance_exists(obj_cutscenefade)) t = 0;
        if (t >= intro_wait && instance_exists(obj_cutscenehandler_midfightattacks))
        {
            pair_enter();
            state = "talk";
        }
    break;
}

// --- whoever's lower on the screen is in front ---
var _sort = [obj_susie, obj_ralsei, obj_lancer, obj_queen];
for (var i = 0; i < array_length(_sort); i++)
    with (_sort[i]) depth = -2000 - scr_get_feet(id).y;

if (instance_exists(chair))
{
    chair.depth = -2000 - (chair.y + chair.bottom_dy);
    // Lancer's in front of it from the moment he hops
    for (var i = 0; i < array_length(chair.riders); i++)
        if (instance_exists(chair.riders[i].inst)) chair.riders[i].inst.depth = chair.depth - 1;
}