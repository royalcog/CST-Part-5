// only the one you're controlling runs this. the follower is moved by obj_plat_controller
if (!leader) exit;

var _locked = global.plat_lock;
var _dir    = _locked ? 0 : (keyboard_check(vk_right) - keyboard_check(vk_left));
var _jp     = !_locked && keyboard_check_pressed(vk_up);
var _jh     = !_locked && keyboard_check(vk_up);

// --- run ---
if (_dir != 0)
{
    vx = clamp(vx + _dir * accel, -walk_spd, walk_spd);
    face = _dir;
}
else
{
    vx = (abs(vx) <= decel) ? 0 : vx - sign(vx) * decel;
}

// --- jump (with a little leeway both ways) ---
grounded = on_ground();
coyote = grounded ? coyote_max : max(0, coyote - 1);
jbuf   = _jp ? buffer_max : max(0, jbuf - 1);
if (jbuf > 0 && coyote > 0)
{
    vy = -jump_spd;
    jbuf = 0;
    coyote = 0;
    grounded = false;
}
if (vy < 0 && !_jh) vy *= jump_cut;   // short hop if you let go

// --- gravity ---
if (!grounded) vy = min(vy + grav, max_fall);

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

animate(vx != 0, grounded, vy);