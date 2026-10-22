// --- tuning ---
sword_count    = 20;   // how many swords this attack throws
spawn_gap      = 45;   // frames between swords at the start...
spawn_gap_end  = 16;   // ...ramping down to this by the last sword
start_delay    = 20;   // beat after the soul appears before the first sword
charge_frames  = 60;   // white -> full red at the start (fires the moment it's fully red)...
charge_frames_end = 28; // ...ramping down to this by the last sword
track_stop     = 0.8;  // stops following the soul at this much red, so there's a tell before it fires
track_lerp     = 0.12; // how quickly it lines up with the soul at the start...
track_lerp_end = 0.22; // ...and by the last sword
launch_speed   = 42;   // px/frame once it fires
sword_scale    = 1.5;
side_gap       = 10;   // gap between the box interior and the sword's tip while charging
hit_radius     = 5;    // the blade is thin, keep this small
damage         = 85;
trail_len      = 5;    // ghost copies left behind while it flies
flight_alpha   = 0.45; // how visible it is mid-flight (low = "barely see its outline")
fade_in_frames = 10;
tip_angle_offset = 0;  // spr_roaringknight_sword assumed to point right; set to 180 if it points left
box_shrink     = 0.8;  // box scale during this attack (1 = normal size)

swords  = [];
spawned = 0;
timer   = start_delay;

diagonal_chance = 0.35; // chance each sword comes in diagonally from a corner instead of straight from a side

if (instance_exists(obj_battlebox))
{
    obj_battlebox.target_scale_x = box_shrink;
    obj_battlebox.target_scale_y = box_shrink;
}