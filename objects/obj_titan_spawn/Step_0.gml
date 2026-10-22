var _fps = game_get_speed(gamespeed_fps);
var _cam = view_camera[0];

// --- clocks ---
t_all++;
var _clock = snd_pos(snd_fountain, t_all);   // seconds into the scene's audio (frame-counted once it ends)
// the rip ends while it's still loud: fade it over its last stretch
if (snd_fountain >= 0 && audio_is_playing(snd_fountain)
    && _clock >= audio_sound_length(snd_fountain) - fountain_fade && once("fountain_fade"))
    audio_sound_gain(snd_fountain, 0, fountain_fade * 1000);
var _g1 = (_clock - con1_at) * 30;           // Deltarune frames since con 1
var _g2 = _g1 - petrify_g;                   // since it petrifies
var _g3 = _g2 - petrify_len_g;               // since the petrifying's done
cur_g2 = _g2;
cur_g3 = _g3;

if (show_geyser) loop_frame += sprite_get_speed(spr_titan_fountain_loop) / _fps;

// --- the Knight getting out of the way ---
if (!knight_moved && _clock >= knight_move_at) start_knight_move();
if (knight_moving)
{
    if (instance_exists(scene) && instance_exists(scene.knight))
    {
        knight_t++;
        var _k = clamp(knight_t / knight_move_time, 0, 1);
        _k = 1 - power(1 - _k, 3);
        scene.knight.x  = lerp(knight_from_x,  knight_from_x  + (knight_aside_x - fx), _k);
        scene.knight_y0 = lerp(knight_from_y0, knight_from_y0 + knight_aside_dy, _k);
        if (_k >= 1) knight_moving = false;
    }
    else knight_moving = false;
}

// --- the camera rising up the geyser ---
if (!pan_done && _clock >= pan_at)
{
    var _k = clamp((_clock - pan_at) / pan_time, 0, 1);
    set_cam_y(cam_home_y - pan_dist * _k * _k * (3 - 2 * _k));
    if (_k >= 1) pan_done = true;
}

// --- pool -> burst -> geyser ---
switch (state)
{
    case "pool":
        pool_white = 1 - clamp((_clock - pool_flash_start) / pool_flash_fade, 0, 1);
        if (_clock >= burst_at)
        {
            pool_white = 0;
            show_burst = true;
            state = "burst";
        }
    break;

    case "burst":
        frame = (sprite_get_number(spr_titan_fountain_burst) - 1) * (_clock - burst_at) / (column_at - burst_at);
        if (frame >= sprite_get_number(spr_titan_fountain_burst) - 1) // its last frame is the full column
        {
            if (instance_exists(obj_dark_fountain)) obj_dark_fountain.visible = false;
            show_burst  = false;
            show_geyser = true;
            loop_frame  = 0;
            state = "geyser";
        }
    break;
}

// --- the dark column behind the geyser: bright teal-white, darkening ---
if (_g1 >= dark_g) dark_visible = true;
if (dark_visible)
{
    var _t = petrify_started ? 0.2 : 1 - clamp((_g1 - 120) / 84, 0, 0.8);
    var _base = make_color_hsv((current_time / 400) mod 256, 50, sin(current_time / 1600) * 10 + 70);
    dark_col  = merge_color(_base, merge_color(c_teal, c_white, 0.5), _t);
    dark_col2 = merge_color(dark_col, c_black, 0.4);
    var _spd = dark_scroll_spd * (2 + _t * 80) / 18;   // fast while it's bright, slow once it's dark
    dark_scroll  += _spd;
    dark_scroll2 += _spd * 1.6;
}

// --- the geyser fizzles out (the pitch drop is already in the audio) ---
if (_g1 >= fizzle_g && once("fizzle"))
{
    show_geyser = false;
    show_fizzle = true;
}
if (show_fizzle)
{
    fizzle_frame = anim_frame(spr_tower_fizzleout, _g1, fizzle_g, fizzle_speed);
    if (_g1 - fizzle_g >= fizzle_len_g) { show_fizzle = false; show_pool = false; }
}

// --- it petrifies: sections of stone build from the bottom of the screen up ---
if (_g2 >= 0 && once("petrify"))
{
    petrify_started = true;
    play_snd(petrify_sound, false, 0.8, 0.5);
    cam_bottom = camera_get_view_y(_cam) + camera_get_view_height(_cam);
}
if (_g2 >= 5 && once("petrify2")) play_snd(petrify_sound, false, 0.8, 0.45);

for (var k = 0; k < seg_count; k++)
{
    if (_g2 >= k * seg_gap_g && once("seg" + string(k)))
    {
        array_push(segs, { x: fx + seg_dx, y: cam_bottom - seg_h * k, born: k * seg_gap_g });
        // the section two below leaves a ghost that stretches out and fades
        if (k >= 2)
        {
            var _s = segs[k - 2];
            array_push(ghosts, { x: _s.x, y: _s.y, img: anim_frame(spr_tower_petrification, _g2, _s.born, seg_speed), born: _g2 });
        }
    }
}
for (var i = array_length(ghosts) - 1; i >= 0; i--)
    if (_g2 - ghosts[i].born >= ghost_len_g) array_delete(ghosts, i, 1);

// --- con 3: cracks, the pillar bursts, the hand ---
if (_g3 >= 0)
{
    cam_cy = camera_get_view_y(_cam) + camera_get_view_height(_cam) / 2;

    for (var i = 0; i < array_length(cracks_def); i++)
    {
        var _c = cracks_def[i];
        if (_g3 >= _c.g && once("crack" + string(i)))
        {
            array_push(cracks, { x: fx + _c.dx, y: cam_cy + _c.dy, spr: _c.spr, debris: _c.debris, born: _c.g });
            play_snd(gravel_sound, false, _c.gain, _c.pitch);
        }
    }

    if (_g3 >= thunder_g && once("thunder")) play_snd(thunder_sound);

    if (_g3 >= handburst_g && once("handburst"))
        handburst = { x: fx, y: cam_cy + handburst_dy, born: handburst_g };

    if (_g3 >= wallblast_g && once("wallblast")) play_snd(wallblast_sound);

    if (_g3 >= foreground_g && once("foreground"))
        foreground = { x: fx, y: cam_cy + handburst_dy };

    if (_g3 >= hand_g && once("hand"))
    {
        hand_x0 = camera_get_view_x(_cam) + camera_get_view_width(_cam) / 2 + hand_start_dx;
        hand_y  = cam_cy + hand_dy;
        show_hand = true;
    }

    if (_g3 >= pan_right_g && once("pan_right")) pan_x_from = get_cam_x();
    if (_g3 >= pan_right_g && !wide)
    {
        var _k = clamp((_g3 - pan_right_g) / pan_right_len_g, 0, 1);
        set_cam_x(pan_x_from + pan_right * _k * _k * (3 - 2 * _k));
    }

    if (_g3 >= big_debris_g && once("big_debris"))
    {
        // twelve rocks thrown off to the right (Deltarune's speeds, halved for 60fps)
        var _off = irandom_range(1, 12);
        for (var i = 0; i < 12; i++)
        {
            array_push(debris, {
                x: fx + random(20), y: hand_y + random_range(-240, 40),
                vx: (random_range(-5, 5) + 12 + i * 3) / 2,
                vy: (-12 - random_range(4 * (i mod 4), 8 * (i mod 4))) / 2,
                g: 3 / 4,
                img: (_off + i) mod 12,
                life: 200   // 100 game frames
            });
        }
    }

    if (show_hand)
    {
        var _hg = _g3 - hand_g;   // frames since the hand came out

        // flies in from the left, easing to a stop
        var _k = clamp(_hg / hand_slide_g, 0, 1);
        hand_x = hand_x0 + hand_slide * (1 - power(1 - _k, 3));

        // plays at 30fps, then loops its last 3 frames
        hand_frame = _hg;
        if (hand_frame > hand_loop_from) hand_frame = hand_loop_from + ((hand_frame - hand_loop_from) mod 3);

        if (_hg >= blast_idx && once("blast"))
        {
            snd_laser = play_snd(laser_sound);
            laser_t = 0;
        }

        if (_hg >= beam_idx)
        {
            show_beam = true;
            var _bg = _hg - beam_idx;
            var _bk = clamp(_bg / beam_slide_g, 0, 1);
            beam_x = hand_x + lerp(beam_from.x, beam_to.x, _bk);
            beam_y = hand_y + lerp(beam_from.y, beam_to.y, _bk);
            if (_bg < beam_start_g) { beam_spr = spr_tower_titanbeam_start; beam_img = floor(_bg); }
            else                    { beam_spr = spr_titanbeam_loop;        beam_img = floor(_bg - beam_start_g) mod sprite_get_number(spr_titanbeam_loop); }
        }

        // the game cuts back to the platform once the hand's looped a while
        if (_hg >= cut_idx && once("cut")) start_wide(_g3);
    }
}

// --- the beam's loop fades in under the blast's tail ---
if (snd_laser >= 0 || laser_t > 0)
{
    laser_t++;
    if (snd_hum < 0 && hum_sound != noone
        && (snd_pos(snd_laser, laser_t) >= hum_at || (snd_laser >= 0 && !audio_is_playing(snd_laser))))
    {
        snd_hum = play_snd(hum_sound, true);
        audio_sound_gain(snd_hum, 0, 0);
        audio_sound_gain(snd_hum, 1, hum_fade);
    }
}

// --- the rocks ---
for (var i = array_length(debris) - 1; i >= 0; i--)
{
    var _d = debris[i];
    _d.vy += _d.g;
    _d.x  += _d.vx;
    _d.y  += _d.vy;
    if (--_d.life <= 0) array_delete(debris, i, 1);
}