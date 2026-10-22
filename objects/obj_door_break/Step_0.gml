t++;
flash = max(flash - 0.08, 0);

if (state == "cut" && t >= break_delay) do_break();

for (var i = array_length(shards) - 1; i >= 0; i--)
{
    var _s = shards[i];
    _s.t++;
    if (!_s.landed)
    {
        _s.vy += shard_gravity;
        _s.x  += _s.vx;
        _s.y  += _s.vy;
        _s.rot += _s.vr;
        if (_s.vy > 0 && _s.y >= _s.floor_y)
        {
            _s.y = _s.floor_y;
            if (_s.bounced) _s.landed = true;
            else
            {
                _s.bounced = true;
                _s.vy  = -_s.vy * 0.3;
                _s.vx *= 0.5;
                _s.vr *= 0.5;
            }
        }
    }
    if (_s.t >= shard_life) array_delete(shards, i, 1);
}