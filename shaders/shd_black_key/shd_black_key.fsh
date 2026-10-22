varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_threshold;   // r+g+b below this counts as "black" and is dropped

void main()
{
    vec4 c = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
    if (c.r + c.g + c.b < u_threshold) discard;
    gl_FragColor = c;
}