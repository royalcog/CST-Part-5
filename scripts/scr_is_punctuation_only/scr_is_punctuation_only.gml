function scr_is_punctuation_only(_str)
{
    var _bare = string_replace(_str, "* ", "");
    var _len = string_length(_bare);

    if (_len == 0) return false;

    for (var i = 1; i <= _len; i++)
    {
        var _ch = string_char_at(_bare, i);
        if (_ch != "." && _ch != "!" && _ch != "?" && _ch != " ")
        {
            return false;
        }
    }
    return true;
}