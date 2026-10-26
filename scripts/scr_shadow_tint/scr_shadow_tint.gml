/// layer begin/end scripts the shadow controller hangs on each layer.
/// only the normal Draw event gets tinted (Draw GUI = textboxes/UI stay clean)
function scr_shadow_tint_begin()
{
    if (event_type != ev_draw || event_number != 0) return;
    if (!instance_exists(obj_shadow_tint)) return;

    var _c = obj_shadow_tint;
    shader_set(shd_shadow_tint);
    shader_set_uniform_f(shader_get_uniform(shd_shadow_tint, "u_tint"), _c.tint_r, _c.tint_g, _c.tint_b);
    shader_set_uniform_f(shader_get_uniform(shd_shadow_tint, "u_strength"), _c.strength);
	
    // flat: put the fade way below everything, so the whole layer gets the full shadow
    shader_set_uniform_f(shader_get_uniform(shd_shadow_tint, "u_y_near"), _c.flat ? 1000000 : _c.near_y);
    shader_set_uniform_f(shader_get_uniform(shd_shadow_tint, "u_y_far"),  _c.flat ? 1000001 : _c.far_y);
}

function scr_shadow_tint_end()
{
    if (event_type != ev_draw || event_number != 0) return;
    shader_reset();
}