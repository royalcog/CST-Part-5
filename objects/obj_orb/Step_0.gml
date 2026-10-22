if (is_fading) // Only happens if you've set this to true
{
    image_alpha -= 0.01; 
    
    if (image_alpha <= 0) 
    {
        instance_destroy(); 
    }
}

if scaleup == true
{
	image_xscale += 2;
	image_yscale += 2;
}

if scaledown == true
{
	if (image_xscale > 1) 
    {
        image_xscale -= 2;
        image_yscale -= 2;
    }
    else 
    {
        image_xscale = 1; // Snap back to original
        image_yscale = 1;
        scaledown = false; // Stop the shrinking process
    }
}

if (!is_colored) {
    // Gradually fade out of white by increasing saturation
    current_sat += sat_speed;
    if (current_sat >= 255) {
        current_sat = 255;
        is_colored = true;
    }
} else {
    // Once it has color, slowly shift through different hues
    current_hue += hue_speed;
    if (current_hue > 255) {
        current_hue = 0;
    }
}

// Apply the updated color
image_blend = make_color_hsv(round(current_hue), round(current_sat), 255);