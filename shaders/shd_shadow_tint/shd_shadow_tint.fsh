varying vec2  v_vTexcoord;
varying vec4  v_vColour;
varying float v_vWorldY;

uniform vec3  u_tint;      // the shadow colour (multiplied in)
uniform float u_strength;  // shadow at its darkest (right by the fountain)
uniform float u_y_near;    // room y where the shadow is darkest
uniform float u_y_far;     // room y where it's faded out completely

void main()
{
    vec4 c = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);

    float k = clamp((v_vWorldY - u_y_near) / (u_y_far - u_y_near), 0.0, 1.0);
    k = k * k * (3.0 - 2.0 * k); // smooth falloff
    float s = u_strength * (1.0 - k);

    c.rgb = mix(c.rgb, c.rgb * u_tint, s);
    gl_FragColor = c;
}