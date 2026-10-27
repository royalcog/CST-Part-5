move_speed = 2;
invulnerable = false;
swap_grace = 0; // frames of protection right after a soul colour change lands (no flashing)
invuln_timer = 0;
invuln_duration = 90; // ~1.5 seconds at 60fps — a bit more breathing room after getting hit
flash_visible = true;
flash_timer = 0;
flash_interval = 6; // frames between flash toggles — faster flicker, same total invuln window
hdir = 0;
vdir = 0;

split_controlled = false; // true while the split-box attack is moving/drawing the soul itself

external_move = false; // true while an attack moves the soul itself (still drawn normally)

// light blue mode (from the Knight's 5th attack on): 3x3 grid, 4 directions
base_sprite      = sprite_index;
lightblue_sprite = spr_soul_lightblue;
lightblue_color  = make_color_rgb(66, 252, 255);
grid_lerp        = 0.35; // how quickly it glides to the next sector
grid_ready_dist  = 3;    // how close it has to be before the next move goes through
grid_c = 1;
grid_r = 1;
grid_buffer = -1;
grid_blocked = array_create(9, false); // sectors the soul can't move into (Knight attack 9 breaks them)

// green mode (Ralsei's shield): stays put in the middle, arrow keys turn the shield
green_sprite = spr_soul_green;
green_color  = make_color_rgb(0, 255, 64);
shield_on    = false;
shield_dir   = 1;    // 0 right, 1 up, 2 left, 3 down (in 8-direction mode: 0 right, then every 45 degrees counterclockwise)
shield_dirs  = 4;    // 4, or 8 for diagonals too (the Knight's last attack turns this on)
shield_angle = 90;
shield_r     = 20;   // how far out the shield sits (swords are blocked/hit at this distance)
shield_arc   = 44;     // half its angle: wide enough to cover both of them (and the beam's full width)
shield_w     = 3;
shield_turn  = 0.45; // how quickly it swings to the new side
shield_pop   = 1;    // 0 -> 1 as it appears
shield_color = make_color_rgb(170, 255, 190);
ring_alpha   = 0.35; // faint circle the shield moves around
soul_mode = "red";
scr_soul_set_mode(id, variable_global_exists("soul_mode") ? global.soul_mode : "red");

grid_alpha        = 0;
grid_alpha_moving = 0.3;  // while gliding to another sector
grid_alpha_idle   = 0.1;  // sitting still (0 = only shows while moving)
grid_line_w       = 2;