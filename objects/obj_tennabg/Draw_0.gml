var scale_x = 853 / 320;
var scale_y = 480 / 170;
var xx = 0;
var yy = 0;
if (paused == 0)
    siner += (1 * rate);
bob_angle += 0.02;
var bob_x = cos(bob_angle) * 3;
var bob_y = sin(bob_angle) * 3;
// Gradient corner panels
draw_set_alpha(1);
var bgcolor1 = make_color_hsv(110, 1800, 220);
draw_rectangle_color(0, 0, 120 * scale_x, 480, c_navy, c_navy, bgcolor1, bgcolor1, false);
draw_rectangle_color(853, 0, 853 - (120 * scale_x), 480, c_navy, c_navy, bgcolor1, bgcolor1, false);
// Floor only
draw_sprite_ext(spr_tenna_enemy_bg_parts, 1, 0, 0, scale_x, scale_y, 0, c_white, 1);
// Oval surface masked to screen
if (!surface_exists(surf3))
    surf3 = surface_create(853, 480);
surface_set_target(surf3);
draw_clear_alpha(c_black, 0);
draw_sprite_ext(spr_tenna_enemy_bg_parts, 2, bob_x, bob_y, scale_x, scale_y, 0, c_white, 1);
surface_reset_target();
var mask_surf3 = surface_create(853, 480);
surface_set_target(mask_surf3);
draw_clear_alpha(c_black, 0);
draw_sprite_ext(spr_tenna_screen_mask, 0, 0, 0, scale_x, scale_y, 0, c_white, 1);
surface_reset_target();
surface_set_target(surf3);
gpu_set_blendmode_ext(bm_zero, bm_src_alpha);
draw_surface(mask_surf3, 0, 0);
gpu_set_blendmode(bm_normal);
surface_reset_target();
surface_free(mask_surf3);
draw_surface(surf3, 0, 0);
// Star tile surface
if (!surface_exists(surf))
    surf = surface_create(853, 480);
surface_set_target(surf);
draw_clear_alpha(c_black, 0);
var tile_size = 80;
for (var tx = -tile_size; tx < 853 + tile_size; tx += tile_size) {
    for (var ty = -tile_size; ty < 480 + tile_size; ty += tile_size) {
        draw_sprite(spr_dw_tv_starbgtile, floor(siner / 3) mod sprite_get_number(spr_dw_tv_starbgtile), tx + (siner mod tile_size), ty + (siner mod tile_size));
    }
}
surface_reset_target();
// Mask
var mask_surf = surface_create(853, 480);
surface_set_target(mask_surf);
draw_clear_alpha(c_black, 0);
draw_sprite_ext(spr_tenna_screen_mask, 0, 0, 0, scale_x, scale_y, 0, c_white, 1);
surface_reset_target();
// Apply mask to star surface
surface_set_target(surf);
gpu_set_blendmode_ext(bm_zero, bm_src_alpha);
draw_surface(mask_surf, 0, 0);
gpu_set_blendmode(bm_normal);
surface_reset_target();
surface_free(mask_surf);
draw_set_alpha(star_fade);
draw_surface(surf, 0, 0);
draw_set_alpha(1);
// Grid lines masked to floor
if (!surface_exists(surf2))
    surf2 = surface_create(853, 480);
surface_set_target(surf2);
draw_clear_alpha(c_black, 0);
var xsep = 90;
var vx = 314;
var xoffset = 100;
scrollx += (3 * rate);
if (scrollx >= 90) scrollx -= 90;
draw_set_color(make_color_rgb(217, 172, 148));
draw_set_alpha(0.6);
for (var i = -9; i < 9; i++) {
    var topx = vx + (((i * xsep) + scrollx) * 0.5) + xoffset;
    draw_line_width(topx, 140, vx + (i * xsep) + scrollx + xoffset, 367, 3);
}
draw_set_color(make_color_rgb(179, 124, 166));
for (var i = -9; i < 9; i++)
    draw_line_width(314 + (i * xsep) + scrollx + xoffset, 367, vx + (i * xsep) + scrollx + xoffset, 387, 3);
// Mask to floor shape
gpu_set_blendmode_ext(bm_zero, bm_src_alpha);
draw_sprite_ext(spr_tenna_enemy_bg_parts, 1, 0, 0, scale_x, scale_y, 0, c_white, 1);
// Cut out screen area
gpu_set_blendmode_ext(bm_zero, bm_src_alpha);
draw_sprite_ext(spr_tenna_screen_mask_inv, 0, 0, 0, scale_x, scale_y, 0, c_white, 1);
// Cut out top
gpu_set_blendmode_ext(bm_zero, bm_zero);
draw_set_alpha(1);
draw_set_color(c_white);
draw_rectangle(0, 0, 853, 150, false);
gpu_set_blendmode(bm_normal);
surface_reset_target();
draw_set_alpha(1);
draw_surface(surf2, 0, 0);
// Black bg reveal
if trio_reveal
{
    var bg_alpha = 1 - star_fade;
    if bg_alpha > 0
    {
        var bg_surf = surface_create(853, 480);
        surface_set_target(bg_surf);
        draw_clear_alpha(c_black, 0);
        draw_set_alpha(1);
        draw_set_color(c_black);
        draw_rectangle(0, 0, 853, 480, false);
        surface_reset_target();
        var bg_mask = surface_create(853, 480);
        surface_set_target(bg_mask);
        draw_clear_alpha(c_black, 0);
        draw_sprite_ext(spr_tenna_screen_mask, 0, 0, 0, scale_x, scale_y, 0, c_white, 1);
        surface_reset_target();
        surface_set_target(bg_surf);
        gpu_set_blendmode_ext(bm_zero, bm_src_alpha);
        draw_surface(bg_mask, 0, 0);
        gpu_set_blendmode(bm_normal);
        surface_reset_target();
        surface_free(bg_mask);
        draw_set_alpha(bg_alpha);
        draw_surface(bg_surf, 0, 0);
        draw_set_alpha(1);
        surface_free(bg_surf);
    }
}
if dim_alpha > 0
{
    draw_set_alpha(dim_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, 853, 480, false);
    draw_set_alpha(1);
}

// Frame on top
draw_sprite_ext(spr_tenna_enemy_bg_parts, 0, 0, 0, scale_x, scale_y, 0, c_white, 1);