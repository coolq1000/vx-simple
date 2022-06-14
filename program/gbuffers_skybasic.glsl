#include "/lib/util.glsl"

#ifdef VSH

void main() {
    gl_Position = ftransform();
}

#endif

#ifdef FSH

#include "/lib/sky.glsl"

void main() {
    /* RENDERTARGETS: 0,1 */
    gl_FragData[FB_GCOLOR] = vec4(get_sky(cameraPosition, get_view_dir(gl_FragCoord.xy / vec2(viewWidth, viewHeight))), 1.0f);
    gl_FragData[FB_GDEPTH] = vec4(0.0f);
}

#endif
