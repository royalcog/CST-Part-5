x_offset += x_vel;
x_vel *= 0.85;

y_offset = lerp(y_offset, peak_offset, 0.3); // eases up and just holds there — no fall-back

timer++;
scale = lerp(scale, target_scale, 0.3);

if (timer > life - 6)
{
    alpha -= 1/6;
}

if (timer >= life)
{
    instance_destroy();
}