if (!instance_exists(target)) { instance_destroy(); exit; }

depth = target.depth - 1;
timer++;

if (timer >= duration)
{
    if (on_finish != noone) on_finish();
    instance_destroy();
}