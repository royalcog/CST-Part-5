if !anim_loop && image_speed != 0
{
    if image_index >= image_number - 1
    {
        image_speed = 0;
        image_index = image_number - 1;
    }
}
/*
bob_timer++;
if bob_timer >= bob_speed
{
    bob_timer = 0;
    bob_index = (bob_index + 1) mod array_length(bob_offsets);
}
y = start_y + bob_offsets[bob_index];*/