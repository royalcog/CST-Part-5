if (!variable_instance_exists(id, "target_x")) target_x = x;
if (!variable_instance_exists(id, "target_y")) target_y = y;

start_x = x;
start_y = y;

// each shot is randomly a small fast bullet or a big slow one, each with its
// own random speed range — travel_frames doubles as the "speed" knob since
// travel is a fixed-frame lerp (fewer frames = arrives faster)
variant = choose("small_fast", "big_slow");

if (variant == "small_fast")
{
    travel_frames  = irandom_range(18, 28);
    bullet_radius  = 4;
    shrapnel_size  = 3;
}
else // "big_slow"
{
    travel_frames  = irandom_range(55, 75);
    bullet_radius  = 11;
    shrapnel_size  = 7;
}

travel_timer = 0;

blink_duration = 100; // ~1.6s telegraph blink before it explodes
blink_timer = 0;
blink_visible = true;
blink_interval = 6;
blink_toggle_timer = blink_interval;

shrapnel_count = 10;
shrapnel_speed = 4;
shrapnel_lifespan = 45;

phase = "travel"; // "travel" -> "blink" -> explode + destroy

sprite_index = -1;
depth = -375;

// each bullet is randomly gold or pink
bullet_color = choose(make_color_rgb(255, 204, 0), make_color_rgb(255, 105, 180));