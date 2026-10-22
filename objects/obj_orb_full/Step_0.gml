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