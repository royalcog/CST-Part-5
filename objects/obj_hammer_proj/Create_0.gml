sprite_index = spr_hammer;
y_vel = 0.3;       // was 2 — starts noticeably slow
gravity = 0.15;    // was 0.4 — builds up gradually instead of slamming down
spin_speed = 10;   // new — spins while falling
bounced = false;
bounce_strength = -10; // gentler hop — gravity naturally pulls it back down after
already_hit = false;
hit_radius = 20;