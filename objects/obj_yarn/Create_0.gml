sprite_index = spr_yarn;
image_speed = 0;
depth = -370;

yarn_scale = 2;
image_xscale = yarn_scale;
image_yscale = yarn_scale;

// margin based on the actual sprite size — but the sprite also spins for
// the tumble effect, so half its width/height alone isn't enough: at some
// rotation angles a CORNER swings out further than that (up to the full
// diagonal from center), even though the center point stays safely
// inside. Using the diagonal half-length instead means it stays fully
// contained no matter which way it's currently facing.
margin = point_distance(0, 0, sprite_get_width(sprite_index) * yarn_scale / 2, sprite_get_height(sprite_index) * yarn_scale / 2);

// DVD-logo style: constant motion, no gravity, no energy loss — it just
// keeps moving forever and bounces cleanly off whichever wall it hits.
// Speed is re-rolled (within a modest band) on every bounce so it doesn't
// look like a perfectly mechanical loop, but the DIRECTION still comes
// from a proper reflection off whatever wall it just hit.
min_speed = 4;
max_speed = 6;
spin_factor = 1.6;

sound_cooldown = 0;

// Position AND velocity both live in the box's own local (unrotated)
// frame, permanently — collision is a completely ordinary bounce against
// a plain, stationary rectangle, nothing rotation-dependent about it. The
// box's actual spin only ever shows up at the very end, purely as a
// rendering transform (scr_box_local_to_world) when placing it on screen.
var _start_dir = random_range(0, 360);
var _start_speed = random_range(min_speed, max_speed);
local_vx = lengthdir_x(_start_speed, _start_dir);
local_vy = lengthdir_y(_start_speed, _start_dir);
local_x = 0;
local_y = 0;

if (instance_exists(obj_battlebox))
{
    var _start = scr_world_to_box_local(x, y);
    local_x = _start.x;
    local_y = _start.y;
}