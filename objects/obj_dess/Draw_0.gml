if room == rm_one && instance_exists(obj_desscircle)
{
    var _sw = 512;
    var _sh = 512;
    var _sx = x - _sw / 2;
    var _sy = y - _sh / 2;
    
    var _surf = surface_create(_sw, _sh);
    surface_set_target(_surf);
    draw_clear_alpha(c_black, 0);
    
    draw_sprite_ext(sprite_index, image_index,
        x - _sx, y - _sy,
        image_xscale, -image_yscale,
        image_angle, image_blend, 0.7);
    
    gpu_set_blendmode(bm_subtract);
	var _circle_y_offset = 6; // adjust this number
	draw_sprite(obj_desscircle.sprite_index, obj_desscircle.image_index,
	    obj_desscircle.x - _sx, obj_desscircle.y - _sy + _circle_y_offset);
	draw_sprite(obj_desscircle.sprite_index, obj_desscircle.image_index,
	    obj_desscircle.x - _sx, obj_desscircle.y - _sy + _circle_y_offset);
	draw_sprite(obj_desscircle.sprite_index, obj_desscircle.image_index,
	    obj_desscircle.x - _sx, obj_desscircle.y - _sy + _circle_y_offset);
	gpu_set_blendmode(bm_normal);
    
    surface_reset_target();
    draw_surface(_surf, _sx, _sy);
    surface_free(_surf);
}
else if room == rm_one
{
    draw_sprite_ext(sprite_index, image_index,
        x, y, image_xscale, -image_yscale,
        image_angle, image_blend, 0.7);
}
draw_self();