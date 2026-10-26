// the battle menu's selected button: the box art's orange (255, 127, 39) becomes yellow, everything else is left alone
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 c = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
    if (c.r > 0.8 && c.g > 0.3 && c.g < 0.7 && c.b < 0.35) c.rgb = vec3(1.0, 1.0, 0.0);
    gl_FragColor = c;
}