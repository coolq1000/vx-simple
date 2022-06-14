#include "/lib/util.glsl"

varying vec2 texcoord;

#ifdef VSH

void main() {
    texcoord = gl_MultiTexCoord0.xy;
    gl_Position = ftransform();
}

#endif

#ifdef FSH

#include "/lib/vx.glsl"
#include "/lib/sky.glsl"

#define MAX_BOUNCE 2

uniform sampler2D noisetex;
uniform int frameCounter;

vec3 hemisphere(float yaw, float pitch, vec3 normal) {
    float normal_yaw = atan(normal.y, normal.x);
    float normal_pitch = -asin(normal.z);

    normal_yaw += yaw * 1.57079632679;
    normal_pitch += pitch * 1.57079632679;

    return vec3(
        cos(normal_yaw) * cos(normal_pitch),
        sin(normal_yaw) * cos(normal_pitch),
        sin(normal_pitch)
    );
}

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 brdf(vec3 direction, vec3 normal, float roughness) {
    vec3 reflected = reflect(direction, normal);
    vec2 noise = (vec2(
        rand(texcoord + 0.451),
        rand(texcoord + 0.251)
    ) - 0.5f) * 2.0f;
    vec3 random_hemisphere = hemisphere(noise.x, noise.y, normal);

    return normalize(mix(reflected, random_hemisphere, roughness));
}

void main() {
    /* RENDERTARGETS: 0,1,2,3 */
    vec3 view_dir = texture2D(gaux1, texcoord).xyz;
    vec3 sun_dir = normalize((gbufferModelViewInverse * vec4(sunPosition, 0.0f)).xyz);
    vec3 color = texture2D(gcolor, texcoord).rgb;
    vec3 normal = decode_normal(texture2D(gnormal, texcoord).xyz);
    float depth = decode_depth(texture2D(gdepth, texcoord).r);

    RayHit trace = voxel_trace(vec3(0), view_dir, false);

    gl_FragData[FB_GCOLOR] = vec4(color, 1.0f);
    gl_FragData[FB_COMPOSITE] = vec4(trace.color.rgb, trace.hit);
}

#endif
