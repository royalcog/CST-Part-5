if trio_reveal
{
    star_fade = max(0, star_fade - 0.02);
    if star_fade <= 0
    {
        trio_alpha = min(1, trio_alpha + 0.02);
    }
}
if instance_exists(obj_battat) obj_battat.image_alpha = trio_alpha;
if instance_exists(obj_pluey) obj_pluey.image_alpha = trio_alpha;
if instance_exists(obj_jongler) obj_jongler.image_alpha = trio_alpha;