t++;

// the camera pan toward the Titan (after "Let's end this.")
if (cam_pan.on)
{
    cam_pan.t++;
    var _pk = clamp(cam_pan.t / cam_pan_time, 0, 1);
    set_cam(lerp(cam_pan.from, cam_pan.to, _pk * _pk * (3 - 2 * _pk)));
    if (_pk >= 1) cam_pan.on = false;
}

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

        // debug (F6): skip the talk, straight to "Let's end this." -> the Titan Spawn -> the battle
        if (variable_global_exists("debug_skip_battle") && global.debug_skip_battle)
        {
            global.debug_skip_battle = false;
            place(obj_susie,  susie_right, susie_x, pair_y);
            place(obj_ralsei, ralsei_right, ralsei_x, pair_y);
            place(obj_queen,  queen_right, queen_x, queen_y);
            with (obj_lancer) instance_destroy();   // he's already left on the chair by now
            with (chair) instance_destroy();
            global.dialogue_self = 7;               // where "Let's end this." leaves it, so Z after the battle opens self_8
            end_this();
        }
		
		// debug (F7): skip the battle and the talk after it, straight to where they stop walking -> the Titan reveal
        if (variable_global_exists("debug_skip_titan") && global.debug_skip_titan)
        {
            global.debug_skip_titan = false;
            var _fx = forward_dx * forward_frames;   // how far they walk after self_9
            set_cam(cam_battle_x + _fx);
            place(obj_susie,  susie_right,  regroup_spots.susie.x  + _fx, regroup_spots.susie.y);
            place(obj_ralsei, ralsei_right, regroup_spots.ralsei.x + _fx, regroup_spots.ralsei.y);
            place(obj_queen,  queen_right,  regroup_spots.queen.x  + _fx, regroup_spots.queen.y);
            with (obj_lancer) instance_destroy();
            with (chair) instance_destroy();
            global.cutscene_lock = true;
            global.dialogue_self = 9;
            state = "titan";
            t = 0;
            scr_call_after_frames(function() { titan_reveal(); }, 30);
        }
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
        var _all = true;
        for (var i = 0; i < array_length(walkers); i++)
        {
            var _w = walkers[i];
            if (_w.done) continue;
            var _f  = _w.by_origin ? { x: _w.o.x, y: _w.o.y } : scr_get_feet(_w.o);
            var _dx = _w.to.x - _f.x, _dy = _w.to.y - _f.y;
            var _d  = point_distance(0, 0, _dx, _dy);
            var _nx = (_d <= battle_walk) ? _w.to.x : _f.x + _dx / _d * battle_walk;
            var _ny = (_d <= battle_walk) ? _w.to.y : _f.y + _dy / _d * battle_walk;
            if (_w.by_origin) { _w.o.x = _nx; _w.o.y = _ny; }
            else set_feet(_w.o, _nx, _ny);

            if (_d <= battle_walk)
            {
                _w.done = true;
                // stand still, facing the Spawn
                if (_w.o == obj_queen) face(obj_queen, queen_battle_sprite);
                else
                {
                    var _face = _w.r;
                    with (_w.o) { sprite_index = _face; last_sprite = _face; image_speed = 0; image_index = 0; }
                }
            }
            else _all = false;
        }
        if (_all) battle_draw();
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