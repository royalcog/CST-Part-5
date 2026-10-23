// bends the flat climb around the tower: the middle of the screen is the front of the tower,
// and things squash in toward its edges the way they would on a cylinder.
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_cx;     // the tower's middle, across the screen (0-1)
uniform float u_r;      // its radius, as a fraction of the screen's width
uniform float u_span;   // how much of the screen's width the front half of the tower is, flat (0-1)
uniform float u_shade;  // how much darker it gets toward its edges (0-1)

void main()
{
    float d = (v_vTexcoord.x - u_cx) / u_r;   // -1 at its left edge, 1 at its right
    if (abs(d) >= 1.0)
    {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);   // off the sides of the tower
    }
    else
    {
        float a  = asin(d);                                  // the angle around the tower
        float fx = u_cx + a / 3.14159265 * u_span;           // where that is on the flat picture
        vec4 col = texture2D(gm_BaseTexture, vec2(fx, v_vTexcoord.y));
        float light = mix(1.0, sqrt(1.0 - d * d), u_shade);
        gl_FragColor = vec4(col.rgb * light, col.a) * v_vColour;
    }
}