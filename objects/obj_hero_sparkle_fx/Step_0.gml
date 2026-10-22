if (!instance_exists(target))
{
    part_system_destroy(psystem);
    instance_destroy();
    exit;
}

timer++;
spawn_timer++;

if (spawn_timer >= spawn_interval && timer < life)
{
    spawn_timer = 0;
    repeat (4)
    {
        var _px = target.x + random_range(-target.sprite_width * 0.4, target.sprite_width * 0.4);
        var _py = target.y - random_range(0, target.sprite_height * 0.8);
        part_particles_create(psystem, _px, _py, ptype, 1);
    }
}

if (timer >= life + 40) // grace period so the last burst finishes fading before cleanup
{
    part_system_destroy(psystem);
    instance_destroy();
}