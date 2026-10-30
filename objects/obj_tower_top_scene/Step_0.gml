t++;

// ---- the ambush: spades flying, their bits, people being shoved
for (var i = array_length(spades) - 1; i >= 0; i--)
{
    var _s = spades[i];
    if (_s.delay > 0) { _s.delay--; continue; }
    if (!_s.thrown) { _s.thrown = true; audio_play_sound(snd_swing, 1, false); }
    _s.rot += spade_spin;
    var _d = point_distance(_s.x, _s.y, _s.tx, _s.ty);
    if (_d <= _s.spd)
    {
        spade_break(_s.tx, _s.ty);
        var _f = _s.on_hit;
        array_delete(spades, i, 1);
        _f();
        continue;
    }
    var _dir = point_direction(_s.x, _s.y, _s.tx, _s.ty);
    _s.x += lengthdir_x(_s.spd, _dir);
    _s.y += lengthdir_y(_s.spd, _dir);
}
// (in the battle) Susie guards against King's spade the moment it's close enough
if (!battle_spade_done && variable_instance_exists(id, "battle_guard_spade") && battle_guard_spade != undefined
 && array_contains(spades, battle_guard_spade))
{
    if (point_distance(battle_guard_spade.x, battle_guard_spade.y, body_mid(obj_susie).x, body_mid(obj_susie).y) <= battle_guard_at)
    {
        scr_bm_pose(obj_susie, spr_susie_defend, 0);   // (her battle sprites line up by origin: a straight swap, still facing King)
        battle_guard_spade = undefined;
    }
}
for (var i = array_length(chunks) - 1; i >= 0; i--)
{
    var _c = chunks[i];
    _c.t++; _c.vy += 0.3; _c.x += _c.vx; _c.y += _c.vy; _c.rot += _c.vr;
    if (_c.t >= 30) array_delete(chunks, i, 1);
}
for (var i = array_length(slides) - 1; i >= 0; i--)
{
    var _sl = slides[i];
    if (!instance_exists(_sl.o)) { array_delete(slides, i, 1); continue; }
    _sl.t++;
    var _k = clamp(_sl.t / _sl.frames, 0, 1);
    var _e = 1 - power(1 - _k, 2);   // eases out
    // moved by how much further it's gone since last frame (so a pose change partway through doesn't get undone)
    var _nx = _sl.dx * _e, _ny = _sl.dy * _e - sin(_k * pi) * _sl.hop;
    _sl.o.x += _nx - _sl.px;
    _sl.o.y += _ny - _sl.py;
    _sl.px = _nx;
    _sl.py = _ny;
    if (_k >= 1) array_delete(slides, i, 1);
}

// the camera pan toward the Titan (after "Let's end this.")
if (cam_pan.on)
{
    cam_pan.t++;
    var _pk = clamp(cam_pan.t / cam_pan.time, 0, 1);
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
            set_cam(cam_battle_x + (forward_cam_pan ? forward_cam_dist : 0));
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
	
    case "party_heal":
    {
        // Ralsei's spell, frame by frame: the heal lands on party_heal_frame, then he holds the last frame
        var _n = sprite_get_number(spr_ralsei_spell);
        var _f = t * party_heal_speed;
        obj_ralsei.image_speed = 0;
        obj_ralsei.image_index = min(_n - 1, _f);
        if (!party_heal_landed && _f >= party_heal_frame)
        {
            party_heal_landed = true;
            audio_play_sound(snd_heal, 1, false);
            party_heal_land(obj_susie,  "Susie");
            party_heal_land(obj_ralsei, "Ralsei");
            party_heal_land(obj_queen,  "Queen");
            party_heal_t = t;
        }
        if (party_heal_landed && _f >= _n - 1 && t - party_heal_t >= party_heal_hold) party_heal_end();
    }
    break;
	
    case "putaway":
    {
        // the draw-weapon animations, backwards (frame by frame here: their own freeze-on-the-last-frame check
        // would stop them straight away going this direction)
        var _k = t * putaway_speed;
        var _done = true;
        for (var i = 0; i < array_length(putaway_list); i++)
        {
            var _o = putaway_list[i].o;
            _o.image_index = max(0, _o.image_number - 1 - _k);
            if (_o.image_index > 0) _done = false;
        }
        if (_done)
        {
            for (var i = 0; i < array_length(putaway_list); i++)
            {
                var _w = putaway_list[i];
                with (_w.o) { sprite_index = _w.walk; last_sprite = _w.walk; image_index = 0; }
            }
            state = "after_battle";
            t = 0;
            putaway_then();
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
var _sort = [obj_susie, obj_ralsei, obj_lancer, obj_queen, obj_king];
for (var i = 0; i < array_length(_sort); i++)
    with (_sort[i]) depth = -2000 - scr_get_feet(id).y;

if (instance_exists(chair))
{
    chair.depth = -2000 - (chair.y + chair.bottom_dy);
    // Lancer's in front of it from the moment he hops
    for (var i = 0; i < array_length(chair.riders); i++)
        if (instance_exists(chair.riders[i].inst)) chair.riders[i].inst.depth = chair.depth - 1;
}
