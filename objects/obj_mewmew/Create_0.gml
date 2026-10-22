event_inherited();

image_xscale = 2;
image_yscale = 2;
depth = -100;
bob_angle = 0;
start_y = y;
ghosted = true;

fading_in = false;

damage_color = make_colour_rgb(199, 185, 215);

char_id = CharID.Pink;

// Lighting
light_on = true;        // always "on" — she's not toggled like gerson's lantern
light_radius = 80;      // smaller, subtle radius around her
light_strength = 0.35;  // just enough to see her, not a full light pool
needtoflip = true;
turn_light_change = false;
vert_light_change = false;
light_offset_x = 3;
light_offset_y = -16;
corrupted = false;