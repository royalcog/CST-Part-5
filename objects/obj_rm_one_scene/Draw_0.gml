// the Knight's ball heading into the door
if (ball.on && ball.alpha > 0)
{
    var _w = sprite_get_width(spr_roark_ball), _h = sprite_get_height(spr_roark_ball);
    var _sx = ball.scale * ball.xs;
    draw_sprite_ext(spr_roark_ball, floor(ball.frame) mod sprite_get_number(spr_roark_ball),
                    ball.x - (_w / 2) * _sx, ball.y - (_h / 2) * ball.scale,
                    _sx, ball.scale, 0, c_white, ball.alpha);
}