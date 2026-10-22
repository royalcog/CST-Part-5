// Check if his position was changed by something outside of this script (like a cutscene)
if (y != expected_y || x != xprevious)
{
    // He is being moved! 
    // Lock his start_y to his current position so he glides smoothly
    start_y = y; 
}
else
{
    // He is NOT being moved, so it is safe to bob
    bob_angle += 0.05;
    y = start_y + sin(bob_angle) * 5;
}

// Save his final Y position at the end of the frame. 
// If it's different next frame, he'll know something else moved him!
expected_y = y;