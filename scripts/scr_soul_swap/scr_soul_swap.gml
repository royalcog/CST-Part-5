/// shared colour changes for the Knight's attacks: the party (and the Knight) change the soul's colour.
///   red       = the Knight swings at the soul (timed to land as the warning ring closes)
///   lightblue = Susie's Rude Buster lands on the soul (the box stays)
///   green     = Ralsei's spell
/// every function runs on the calling attack instance. call scr_soul_swap_init() in Create,
/// scr_soul_swap_step() in Step, scr_soul_swap_draw() in Draw and scr_soul_swap_cleanup() in Clean Up.

function scr_soul_swap_init()
{
    if (!variable_instance_exists(id, "knight_swing_lead")) scr_knight_swing_init();

    // --- tuning ---
    sw_warn          = 30;   // shortest warning ring before a change lands
    sw_ring_r        = 34;   // how big the ring starts
    sw_change_sound  = snd_sparklegem;
    sw_change_gain   = 1.5;
    sw_flash_frames  = 20;
    sw_flash_radius  = 40;
    sw_green_glide   = 10;   // frames the soul takes to slide to the middle when it turns green
    sw_cap           = 150;  // never wait longer than this for a cast
    sw_grace         = 20;   // frames the soul can't be hit right after a change lands (green adds its slide to the middle on top)

    sw_col_red       = c_red;
    sw_col_blue      = make_color_rgb(66, 252, 255);
    sw_col_green     = make_color_rgb(0, 255, 64);

    sw_ralsei_cast_sprite = spr_ralsei_spell;
    sw_ralsei_idle_sprite = spr_ralsei_battle_idle;
    sw_ralsei_cast_frame  = 4;   // frame of his spell where the magic goes off
    sw_ralsei_cast_sound  = snd_spell_pacify;
    sw_ralsei_est         = 30;  // about how long his cast takes (also the fallback if he's down)
    sw_susie_est          = 60;  // about how long the buster takes to wind up + land (also the fallback if she's down)

    sw_mark_sound    = snd_slash;
    sw_mark_frames   = 14;   // the red slash across the soul when the Knight's swing lands
    sw_mark_len      = 44;

    // --- state ---
    sw_swapping    = false;
    sw_el          = 0;
    sw_est         = 1;
    sw_next        = "red";
    sw_buster      = noone;
    sw_ralsei_cast = false;
    sw_swing_at    = 0;
    sw_swung       = false;
    sw_glide_t     = 0;
    sw_mark_t      = 0;
    sw_mark_x      = 0;
    sw_mark_y      = 0;
    sw_mark_ang    = 0;
    sw_flash_t     = 0;
    sw_flash_x     = 0;
    sw_flash_y     = 0;
    sw_flash_col   = c_white;
    sw_saved_mode  = variable_global_exists("soul_mode") ? global.soul_mode : "red";
}

function scr_soul_swap_soul()
{
    return instance_exists(obj_soul) ? instance_find(obj_soul, 0) : noone;
}

function scr_soul_swap_color(_m)
{
    if (_m == "lightblue") return sw_col_blue;
    if (_m == "green")     return sw_col_green;
    return sw_col_red;
}

/// true while a change is on its way (or the soul's still sliding to the middle for green)
function scr_soul_swap_busy()
{
    return sw_swapping || sw_glide_t > 0;
}

/// starts the change. does nothing if the soul's already that colour
function scr_soul_swap_start(_mode)
{
    var _s = scr_soul_swap_soul();
    if (!instance_exists(_s)) return;
    if (_s.soul_mode == _mode && !sw_swapping) return;

    sw_next     = _mode;
    sw_swapping = true;
    sw_el       = 0;
    sw_est      = sw_warn;
    sw_buster   = noone;

    if (_mode == "red")
    {
        // the ring always gets at least sw_warn; the swing starts late enough to land right as it closes
        sw_est      = max(sw_warn, knight_swing_lead);
        sw_swing_at = sw_est - knight_swing_lead;
        sw_swung    = false;
    }
    else if (_mode == "green")
    {
        sw_est = sw_ralsei_est;
        sw_ralsei_cast = instance_exists(obj_ralsei) && scr_party_is_up(obj_ralsei);
        if (sw_ralsei_cast)
        {
            scr_set_battle_sprite(obj_ralsei, sw_ralsei_cast_sprite, noone, false);
            if (sw_ralsei_cast_sound != noone) audio_play_sound(sw_ralsei_cast_sound, 1, false);
        }
    }
    else if (_mode == "lightblue")
    {
        sw_est = sw_susie_est;
        if (instance_exists(obj_susie) && scr_party_is_up(obj_susie))
        {
            sw_buster = instance_create_depth(0, 0, depth - 1, obj_rude_buster);
            sw_buster.break_on_hit = false; // it hits the soul, the box stays
            sw_buster.target_x = _s.x;
            sw_buster.target_y = _s.y;
        }
    }
}

/// has whoever's changing it landed it yet?
function scr_soul_swap_ready()
{
    if (sw_el >= sw_cap) return true;
    switch (sw_next)
    {
        case "green":
            if (!sw_ralsei_cast) return sw_el >= sw_ralsei_est;
            if (!instance_exists(obj_ralsei) || obj_ralsei.sprite_index != sw_ralsei_cast_sprite) return true; // interrupted (hurt etc)
            return floor(obj_ralsei.image_index) >= sw_ralsei_cast_frame;

        case "lightblue":
            if (sw_buster == noone) return sw_el >= sw_susie_est;
            if (!instance_exists(sw_buster)) return true;
            return sw_buster.landed;

        default: // red: on the Knight's hit frame
            return sw_el >= sw_est;
    }
}

/// the change lands
function scr_soul_swap_land()
{
    sw_swapping = false;
    var _s = scr_soul_swap_soul();
    if (!instance_exists(_s)) return;

    global.soul_mode = sw_next;
    scr_soul_set_mode(_s, sw_next); // light blue also puts it back on the middle sector
	
    // a moment to get your bearings: nothing can hit it while it's being moved/slid into place
    _s.swap_grace = sw_grace + ((sw_next == "green") ? sw_green_glide : 0);

    if (sw_next == "green")
    {
        _s.shield_on  = true;
        _s.shield_pop = 0;
        _s.external_move = true; // slides to the middle first, then the shield takes over
        sw_glide_t = sw_green_glide;
    }
    else
    {
        _s.shield_on = false;
        _s.external_move = false;
        sw_glide_t = 0;
    }

    if (sw_next == "red")
    {
        // his swing lands: a red slash right across the soul
        sw_mark_t   = sw_mark_frames;
        sw_mark_x   = _s.x;
        sw_mark_y   = _s.y;
        sw_mark_ang = choose(30, 150) + irandom_range(-15, 15);
        if (sw_mark_sound != noone) audio_play_sound(sw_mark_sound, 1, false);
    }

    sw_flash_t   = sw_flash_frames;
    sw_flash_x   = _s.x;
    sw_flash_y   = _s.y;
    sw_flash_col = scr_soul_swap_color(sw_next);
    if (sw_change_sound != noone) audio_play_sound(sw_change_sound, 1, false, sw_change_gain);
    scr_camera_shake(2, 8);
}

function scr_soul_swap_step()
{
    var _s = scr_soul_swap_soul();
    if (sw_flash_t > 0) sw_flash_t--;
    if (sw_mark_t > 0)  sw_mark_t--;

    if (sw_swapping)
    {
        sw_el++;

        // red: the Knight starts his swing so it lands as the ring closes
        if (sw_next == "red" && !sw_swung && sw_el >= sw_swing_at)
        {
            sw_swung = true;
            scr_knight_swing();
        }

        // Susie's buster follows the soul until she actually throws it
        if (instance_exists(sw_buster) && sw_buster.state == "windup" && instance_exists(_s))
        {
            sw_buster.target_x = _s.x;
            sw_buster.target_y = _s.y;
        }

        if (scr_soul_swap_ready()) scr_soul_swap_land();
    }

    // Ralsei goes back to his battle idle once the spell's played out
    if (sw_ralsei_cast && instance_exists(obj_ralsei) && obj_ralsei.sprite_index == sw_ralsei_cast_sprite && obj_ralsei.image_speed == 0)
    {
        if (scr_party_is_up(obj_ralsei)) scr_set_battle_sprite(obj_ralsei, sw_ralsei_idle_sprite, noone, true);
        sw_ralsei_cast = false;
    }

    // green: slide to the middle, then the shield takes over
    if (sw_glide_t > 0 && instance_exists(_s))
    {
        var _c = scr_box_center();
        _s.x = lerp(_s.x, _c.x, 0.35);
        _s.y = lerp(_s.y, _c.y, 0.35);
        sw_glide_t--;
        if (sw_glide_t <= 0) _s.external_move = false;
    }
}

function scr_soul_swap_draw()
{
    var _s = scr_soul_swap_soul();
    gpu_set_blendmode(bm_add);

    // the next colour closing in on the soul
    if (sw_swapping && instance_exists(_s))
    {
        var _left  = sw_est - sw_el;
        var _k     = clamp(_left / sw_est, 0, 1); // 1 -> 0 (holds small if the cast runs long)
        var _blink = (_left < 10) && ((sw_el div 2) mod 2 == 0);
        draw_set_color(_blink ? c_white : scr_soul_swap_color(sw_next));
        draw_set_alpha(0.4 + 0.6 * (1 - _k));
        draw_circle(_s.x, _s.y, 8 + sw_ring_r * _k, true);
        draw_circle(_s.x, _s.y, 7 + sw_ring_r * _k, true);
    }

    // the Knight's slash across the soul when he turns it red
    if (sw_mark_t > 0)
    {
        var _k  = 1 - sw_mark_t / sw_mark_frames;
        var _hl = sw_mark_len / 2 * (0.6 + 0.4 * _k);
        var _x1 = sw_mark_x - lengthdir_x(_hl, sw_mark_ang), _y1 = sw_mark_y - lengthdir_y(_hl, sw_mark_ang);
        var _x2 = sw_mark_x + lengthdir_x(_hl, sw_mark_ang), _y2 = sw_mark_y + lengthdir_y(_hl, sw_mark_ang);
        draw_set_color(sw_col_red);
        draw_set_alpha(0.7 * (1 - _k));
        draw_line_width(_x1, _y1, _x2, _y2, 10 * (1 - _k) + 2);
        draw_set_color(c_white);
        draw_set_alpha(1 - _k);
        draw_line_width(_x1, _y1, _x2, _y2, max(4 * (1 - _k), 1));
    }

    // burst when it changes
    if (sw_flash_t > 0)
    {
        var _k = 1 - sw_flash_t / sw_flash_frames;
        draw_set_color(sw_flash_col);
        draw_set_alpha((1 - _k) * 0.8);
        draw_circle(sw_flash_x, sw_flash_y, sw_flash_radius * _k, false);
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

function scr_soul_swap_cleanup()
{
    global.soul_mode = sw_saved_mode; // later rounds go back to the soul they had

    // Ralsei never gets stuck mid-spell
    if (instance_exists(obj_ralsei) && scr_party_is_up(obj_ralsei)
        && (obj_ralsei.sprite_index == sw_ralsei_cast_sprite || obj_ralsei.sprite_index == spr_ralsei_spellready))
    {
        scr_set_battle_sprite(obj_ralsei, sw_ralsei_idle_sprite, noone, true);
    }
}