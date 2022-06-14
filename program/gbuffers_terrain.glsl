#include "/lib/util.glsl"

varying vec3 frag_pos;
varying vec2 texcoord;
varying vec3 color;
varying vec3 normal;

#ifdef VSH

void main() {
    frag_pos = gl_Vertex.xyz;
    gl_Position = ftransform();
    texcoord = gl_MultiTexCoord0.xy;
    color = gl_Color.rgb;
    normal = (vec4(gl_Normal, 0.0f)).xyz;
}

#endif

#ifdef FSH

uniform sampler2D texture;

void main() {
    /* RENDERTARGETS: 0,1,2,3,4 */
    gl_FragData[FB_GCOLOR] = vec4(color, 1.0f) * texture2D(texture, texcoord);
    gl_FragData[FB_GNORMAL] = vec4(encode_normal(normal), 1.0f);
    gl_FragData[FB_GDEPTH] = vec4(encode_depth(length(frag_pos)), 0.0f, 0.0f, 1.0f);
    gl_FragData[FB_GAUX1] = vec4(normalize(frag_pos), 1.0f);
}

#endif
