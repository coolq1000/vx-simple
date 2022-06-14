#include "/lib/util.glsl"

varying vec2 texcoord;

#ifdef VSH

void main() {
    texcoord = gl_MultiTexCoord0.xy;
    gl_Position = ftransform();
}

#endif

#ifdef FSH

void main() {
    vec4 color = texture2D(gcolor, texcoord);
    vec4 trace = texture2D(composite, texcoord);
    if (trace.a > 0.5f) {
        gl_FragData[FB_GCOLOR] = mix(color, trace, step(texcoord.x, 0.5f));
    } else {
        gl_FragData[FB_GCOLOR] = color;
    }
}

#endif
