// the ball heading into the door
if (ball.on)
{
    ball.t++;
    var _k = min(ball.t / leave_frames, 1);
    var _e = (_k < 0.5) ? 2 * _k * _k : 1 - power(-2 * _k + 2, 2) / 2;
    ball.x = lerp(ball.sx, ball.tx, _e);
    ball.y = lerp(ball.sy, ball.ty, _e);
    ball.alpha = (_k < 0.5) ? 1 : 1 - (_k - 0.5) / 0.5;
    ball.frame += sprite_get_speed(spr_roark_ball) / game_get_speed(gamespeed_fps);
    if (_k >= 1)
    {
        ball.on = false;
        with (obj_knight) instance_destroy();
    }
}

// Susie's point loops until her line is fully typed, then lands on its last frame
if (point_looping && instance_exists(obj_susie))
{
    if (instance_exists(obj_textbox))
    {
        point_saw_box = true;
        var _done = false;
        with (obj_textbox) _done = (draw_char >= text_length[page]);
        if (_done) { obj_susie.image_speed = 0; point_looping = false; }
    }
    else if (point_saw_box)
    {
        // box closed before we caught it finishing (skipped)
        obj_susie.anim_loop = false;
        point_looping = false;
    }
}

if (!run_steps())
{
    global.cutscene_lock = false;
    if (on_done != undefined) on_done();
    instance_destroy();
    exit;
}

if (action == "") exit;
t++;

switch (action)
{
    // ------------------------------------------------ everyone into place
    case "setup":
        switch (sub)
        {
            case "start":
            {
                // the Knight, standing to the right of the cauldron
                var _k = instance_exists(obj_knight) ? obj_knight : instance_create_layer(0, 0, "Instances", obj_knight);
                with (_k)
                {
                    sprite_index = other.knight_stand_sprite;
                    image_index  = image_number - 1;
                    image_speed  = 0;
                    anim_loop    = false;
                    image_xscale = other.knight_facing;
                    x = other.knight_feet_x - other.knight_stand_feet.x * image_xscale;
                    y = other.knight_feet_y - other.knight_stand_feet.y * image_yscale;
                    start_y   = y;
                    bob_angle = 0;
                    ball_phase = 3; // hovering
                }

                // Susie and Ralsei
                var _s = instance_exists(obj_susie)  ? obj_susie  : instance_create_layer(susie_x, susie_y, "Instances", obj_susie);
                var _r = instance_exists(obj_ralsei) ? obj_ralsei : instance_create_layer(ralsei_x, ralsei_y, "Instances", obj_ralsei);
                stand(_s, spr_susie_walk_right_neutral);
                stand(_r, spr_ralsei_walk_right_neutral);
                _s.image_alpha = 1; _s.visible = true;
                _r.image_alpha = 1; _r.visible = true;

                var _bottom = camera_get_view_y(view_camera[0]) + camera_get_view_height(view_camera[0]) + 50;
                if (walk_in)
                {
                    set_feet(_s, susie_x,  _bottom);
                    set_feet(_r, ralsei_x, _bottom + 10);
                    runners = [
                        susie_runner([{ x: susie_x, y: susie_y }], walk_in_speed, 1, 0, false),
                        ralsei_runner([{ x: ralsei_x, y: ralsei_y }], walk_in_speed, 1, ralsei_walk_wait, false)
                    ];
                }
                else
                {
                    set_feet(_s, susie_x, susie_y);
                    set_feet(_r, ralsei_x, ralsei_y);
                    runners = [];
                }
                go("walk");
            }
            break;

            case "walk":
            {
                var _done = true;
                for (var i = 0; i < array_length(runners); i++) if (!step_runner(runners[i])) _done = false;
                if (_done)
                {
                    stand(obj_susie,  spr_susie_walk_right_neutral);
                    stand(obj_ralsei, spr_ralsei_walk_right_neutral);
                    if (!instance_exists(obj_cutscenefade)) finish(); // wait for the fade in
                }
            }
            break;
        }
    break;

    // ------------------------------------------------ Susie points up at him
    case "susie_point":
        if (instance_exists(obj_susie))
        {
            obj_susie.sprite_index = susie_point_sprite;
            obj_susie.image_index  = 0;
            obj_susie.image_speed  = 1;
            obj_susie.anim_loop    = true;
        }
        point_looping = true;
        point_saw_box = false;
        finish();
    break;

    // ------------------------------------------------ the Knight cuts the door down
    case "knight_slash":
        switch (sub)
        {
            case "start":
                if (!instance_exists(obj_knight)) { finish(); break; }
                knight_swap(spr_knight_attack, knight_stand_feet, knight_attack_feet, knight_attack_facing);
                with (obj_knight) { image_index = 0; image_speed = 1; anim_loop = false; }
                audio_play_sound(knight_swing_sound, 1, false);
                go("swing");
            break;

            case "swing":
                if (!instance_exists(obj_knight)) { finish(); break; }
                if (!variable_struct_exists(saved, "cut") && obj_knight.image_index >= knight_hit_frame)
                {
                    saved.cut = true;
                    with (door) slash();
                }
                if (obj_knight.image_speed == 0 && variable_struct_exists(saved, "cut")) go("hold");
            break;

            case "hold":
                // Ralsei and Susie see the door go
                if (!variable_struct_exists(saved, "ralsei") && door.state == "broken")
                {
                    saved.ralsei = true;
                    pose_facing(obj_ralsei, spr_ralsei_surprised, 2); // that sprite faces left, mirrored to face right

                    // Susie: shocked until she runs in after him, standing on the same foot she was pointing on
                    point_looping = false;
                    if (instance_exists(obj_susie))
                    {
                        if (obj_susie.sprite_index == susie_point_sprite)
                            pose_on_foot(obj_susie, spr_susie_shocked, 2, susie_point_foot, susie_shock_foot);
                        else
                            pose_facing(obj_susie, spr_susie_shocked, 2);
                    }
                }
                if (t >= knight_after_swing && door.state == "broken")
                {
                    knight_swap(knight_stand_sprite, knight_attack_feet, knight_stand_feet, knight_facing);
                    with (obj_knight) { image_index = image_number - 1; image_speed = 0; }
                    finish();
                }
            break;
        }
    break;

    // ------------------------------------------------ back into the ball, through the door
    case "knight_enter":
        switch (sub)
        {
            case "start":
                if (!instance_exists(obj_knight)) { finish(); break; }
                scr_knight_to_ball();
                go("reverse");
            break;

            case "reverse":
                if (!instance_exists(obj_knight)) { finish(); break; }
                if (obj_knight.reverse_phase == 2 || t > 150)
                {
                    with (obj_knight)
                    {
                        other.ball.x = x + ((sprite_get_bbox_left(sprite_index) + sprite_get_bbox_right(sprite_index) + 1) / 2 - sprite_get_xoffset(sprite_index)) * image_xscale;
                        other.ball.y = y + ((sprite_get_bbox_top(sprite_index) + sprite_get_bbox_bottom(sprite_index) + 1) / 2 - sprite_get_yoffset(sprite_index)) * image_yscale;
                        other.ball.xs    = sign(image_xscale);
                        other.ball.scale = abs(image_xscale);
                        reverse_phase = 0;
                        visible = false;
                    }
                    ball.sx = ball.x;  ball.sy = ball.y;
                    ball.tx = door_x;  ball.ty = ball_target_y;
                    ball.t = 0;  ball.frame = 0;  ball.alpha = 1;
                    ball.on = true;
                    go("fly");
                }
            break;

            case "fly":
                if (!ball.on) finish();
            break;
        }
    break;

    // ------------------------------------------------ Ralsei runs in (around the cauldron), Susie right behind
    case "run_in":
        switch (sub)
        {
            case "start":
                runners = [];
                if (instance_exists(obj_ralsei) && obj_ralsei.image_xscale < 0)
                    pose_facing(obj_ralsei, spr_ralsei_walk_right_neutral, 2);
                if (instance_exists(obj_ralsei))
                    array_push(runners, ralsei_runner(door_path(obj_ralsei), ralsei_run_speed, ralsei_run_anim, 0, true));
                if (instance_exists(obj_susie))
                {
                    var _sp = door_path(obj_susie);
                    // still shocked: start her path at her planted foot, not the shocked canvas's bottom (3px lower)
                    if (obj_susie.sprite_index == spr_susie_shocked)
                        _sp[0].y = obj_susie.y + (susie_shock_foot.y - sprite_get_yoffset(spr_susie_shocked)) * obj_susie.image_yscale;
                    array_push(runners, susie_runner(_sp, susie_run_speed, susie_run_anim, susie_follow_wait, true));
                }
                go("run");
            break;

            case "run":
            {
                var _done = true;
                for (var i = 0; i < array_length(runners); i++) if (!step_runner(runners[i])) _done = false;
                if (_done) finish();
            }
            break;
        }
    break;
}