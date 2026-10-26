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
	
    case "spawns":
        // everyone stops walking the moment the first one's down
        if (array_length(spawns) > 0 && instance_exists(spawns[0]) && spawns[0].landed)
        {
            spawn_shock();
            state = "shock";
            t = 0;
        }
    break;

    case "shock":
        if (t >= shock_hold) battle_slide_start();
    break;

    case "battle_slide":
    {
        var _k = clamp(t / battle_move, 0, 1);
        _k = 1 - power(1 - _k, 3);
        set_feet(obj_susie,  lerp(slide_from.susie.x,  battle_spots.susie.x,  _k), lerp(slide_from.susie.y,  battle_spots.susie.y,  _k));
        set_feet(obj_ralsei, lerp(slide_from.ralsei.x, battle_spots.ralsei.x, _k), lerp(slide_from.ralsei.y, battle_spots.ralsei.y, _k));
        set_feet(obj_queen,  lerp(slide_from.queen.x,  battle_spots.queen.x,  _k), lerp(slide_from.queen.y,  battle_spots.queen.y,  _k));
        if (_k >= 1) battle_draw();
    }
    break;

    case "battle_draw":
    {
        // the intro animations freeze on their last frame when they're done (anim_loop = false)
        var _done = obj_susie.image_speed == 0 && obj_ralsei.image_speed == 0;
        if (_done && state != "battle_wait") { state = "battle_wait"; t = 0; }
    }
    break;

    case "battle_wait":
        if (t >= battle_wait)
        {
            with (obj_susie)  { sprite_index = spr_susie_battle_idle;  image_index = 0; image_speed = 1; anim_loop = true; }
            with (obj_ralsei) { sprite_index = spr_ralsei_battle_idle; image_index = 0; image_speed = 1; anim_loop = true; }
            set_feet(obj_susie,  battle_spots.susie.x,  battle_spots.susie.y);
            set_feet(obj_ralsei, battle_spots.ralsei.x, battle_spots.ralsei.y);
            scr_titanspawn_battle_start();
            state = "battle";
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