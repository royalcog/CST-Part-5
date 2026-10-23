// blinking after a hit (both of them)
if (invuln > 0) invuln--;
image_alpha = (invuln > 0 && (invuln div 4) mod 2 == 0) ? 0.4 : 1;
if (attack_cool > 0) attack_cool--;

// only the one you're controlling runs the rest. the follower is moved by obj_plat_controller
if (!leader)
{
    if (attacking) attack_step();   // the follower can attack too (in the scene)
    exit;
}

var _locked = global.plat_lock;
var _hurt   = hurt_t > 0;
if (_hurt) hurt_t--;
var _free   = !_locked && !_hurt && !attacking;
var _dir    = _free ? (keyboard_check(vk_right) - keyboard_check(vk_left)) : 0;
var _jp     = _free && keyboard_check_pressed(vk_up);
var _jh     = !_locked && keyboard_check(vk_up);

grounded = on_ground();
if (_free && keyboard_check_pressed(attack_key)) start_attack();

// --- run (knockback carries you while you're hurt) ---
if (!_hurt)
{
    if (_dir != 0)
    {
        vx = clamp(vx + _dir * accel, -walk_spd, walk_spd);
        face = _dir;
    }
    else
    {
        vx = (abs(vx) <= decel) ? 0 : vx - sign(vx) * decel;
    }
}

// --- jump (with a little leeway both ways) ---
coyote = grounded ? coyote_max : max(0, coyote - 1);
jbuf   = _jp ? buffer_max : max(0, jbuf - 1);
if (jbuf > 0 && coyote > 0)
{
    vy = -jump_spd;
    jbuf = 0;
    coyote = 0;
    grounded = false;
}
if (vy < 0 && !_jh && !_hurt) vy *= jump_cut;   // short hop if you let go

// --- gravity ---
if (!grounded || vy < 0) vy = min(vy + grav, max_fall);

// --- move, a pixel at a time ---
xr += vx;
var _mx = round(xr);
xr -= _mx;
repeat (abs(_mx))
{
    var _s = sign(_mx);
    if (!solid_at(x + _s, y)) x += _s;
    else { vx = 0; xr = 0; break; }
}

x = scr_plat_wrap(x);   // off one side of the tower, back on the other

yr += vy;
var _my = round(yr);
yr -= _my;
repeat (abs(_my))
{
    var _s = sign(_my);
    if (_s > 0)
    {
        if (solid_at(x, y + 1) || ledge_under(x, y)) { vy = 0; yr = 0; break; }   // landed
        y += 1;
    }
    else
    {
        if (solid_at(x, y - 1)) { vy = 0; yr = 0; break; }   // bonked its head
        y -= 1;
    }
}

grounded = on_ground();
if (grounded && vy > 0) vy = 0;

if (attacking && attack_step()) exit;
image_yscale = 2;
animate(vx != 0 && !_hurt, grounded, vy);