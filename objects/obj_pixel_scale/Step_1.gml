if (!enabled) exit;
application_surface_draw_enable(false);   // Post Draw draws it (the climb turns this back on when it ends)
if (window_get_width() != last_w || window_get_height() != last_h) apply();   // resized / fullscreen toggled