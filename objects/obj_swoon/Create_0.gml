depth = -10001;   // GUI also draws in depth order; this keeps it above obj_textbox (-9999)
duration  = 180;
timer     = 0;
on_finish = undefined;
sounds    = [];
sound_gain  = 5;   // set by scr_swoon
fade_frames = 10;  // audio fades out over the last this-many frames of the swoon

image_xscale = 2;
image_yscale = 2;

// where the sprite's top-left sits on screen (GUI coords)
draw_x = 0;
draw_y = 0;