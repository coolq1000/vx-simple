
/* shadow texture */
const int shadowMapResolution = 1024;
const bool shadowtexNearest = true;
const bool shadowcolor0Nearest = true;
const bool shadowcolor1Nearest = true;

/* viewport */
uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;

/* clipping plane */
uniform float far, near;

/* buffer settings
const int gcolorFormat = RGB16;
const int gdepthFormat = R16;
const int gnormalFormat = RGB8;
const int compositeFormat = RGBA32F;
const int gaux1Format = RGB32F;
const bool gcolorClear = false;
const bool compositeClear = false;
const int noiseTextureResolution = 256;
const float ambientOcclusionLevel = 0.0f;
*/

/* samplers */
uniform sampler2D gcolor;
uniform sampler2D gdepth;
uniform sampler2D gnormal;
uniform sampler2D composite;
uniform sampler2D gaux1;
uniform sampler2D gaux2;
uniform sampler2D gaux3;
uniform sampler2D gaux4;
uniform sampler2D shadow;
uniform sampler2D shadowcolor0;

/* camera pos */
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

/* time */
uniform int worldTime;

/* sun & moon */
uniform vec3 sunPosition;
uniform vec3 moonPosition;
const float sunPathRotation = -40.0f;

/* matrices */
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

/* util functions */
float linear_depth(float depth) { return (2.0 * near) / (far + near - depth * (far - near)); }
float encode_depth(float depth) { return depth / far; }
float decode_depth(float depth) { return depth * far; }
vec3 encode_normal(vec3 normal) { return (normal + 1.0f) / 2.0f; }
vec3 decode_normal(vec3 normal) { return (normal * 2.0f) - 1.0f; }

/* framebuffers */
#define FB_GCOLOR 0
#define FB_GDEPTH 1
#define FB_GNORMAL 2
#define FB_COMPOSITE 3
#define FB_GAUX1 4
#define FB_GAUX2 5
#define FB_GAUX3 6
#define FB_GAUX4 7

/* transforms */
bool within_tex(vec2 texcoord) {
    return texcoord.x > 0.0f && texcoord.x < 1.0f && texcoord.y > 0.0f && texcoord.y < 1.0f;
}

vec3 get_world_pos(vec2 coord, float depth) {
    vec4 pos = vec4(vec3(coord, depth) * 2.0 - 1.0, 1.0);
	pos = gbufferModelViewInverse * pos;
	return pos.xyz;
}

vec3 get_view_dir(vec2 coord) {
    coord.x *= aspectRatio;
    coord.x -= (aspectRatio - 1.0f) / 2.0f;
    return normalize(get_world_pos(coord, 0.074f));
}

/* poisson disc */
const vec2 Poisson64[64] = vec2[](
    vec2(-0.934812, 0.366741),
    vec2(-0.918943, -0.0941496),
    vec2(-0.873226, 0.62389),
    vec2(-0.8352, 0.937803),
    vec2(-0.822138, -0.281655),
    vec2(-0.812983, 0.10416),
    vec2(-0.786126, -0.767632),
    vec2(-0.739494, -0.535813),
    vec2(-0.681692, 0.284707),
    vec2(-0.61742, -0.234535),
    vec2(-0.601184, 0.562426),
    vec2(-0.607105, 0.847591),
    vec2(-0.581835, -0.00485244),
    vec2(-0.554247, -0.771111),
    vec2(-0.483383, -0.976928),
    vec2(-0.476669, -0.395672),
    vec2(-0.439802, 0.362407),
    vec2(-0.409772, -0.175695),
    vec2(-0.367534, 0.102451),
    vec2(-0.35313, 0.58153),
    vec2(-0.341594, -0.737541),
    vec2(-0.275979, 0.981567),
    vec2(-0.230811, 0.305094),
    vec2(-0.221656, 0.751152),
    vec2(-0.214393, -0.0592364),
    vec2(-0.204932, -0.483566),
    vec2(-0.183569, -0.266274),
    vec2(-0.123936, -0.754448),
    vec2(-0.0859096, 0.118625),
    vec2(-0.0610675, 0.460555),
    vec2(-0.0234687, -0.962523),
    vec2(-0.00485244, -0.373394),
    vec2(0.0213324, 0.760247),
    vec2(0.0359813, -0.0834071),
    vec2(0.0877407, -0.730766),
    vec2(0.14597, 0.281045),
    vec2(0.18186, -0.529649),
    vec2(0.188208, -0.289529),
    vec2(0.212928, 0.063509),
    vec2(0.23661, 0.566027),
    vec2(0.266579, 0.867061),
    vec2(0.320597, -0.883358),
    vec2(0.353557, 0.322733),
    vec2(0.404157, -0.651479),
    vec2(0.410443, -0.413068),
    vec2(0.413556, 0.123325),
    vec2(0.46556, -0.176183),
    vec2(0.49266, 0.55388),
    vec2(0.506333, 0.876888),
    vec2(0.535875, -0.885556),
    vec2(0.615894, 0.0703452),
    vec2(0.637135, -0.637623),
    vec2(0.677236, -0.174291),
    vec2(0.67626, 0.7116),
    vec2(0.686331, -0.389935),
    vec2(0.691031, 0.330729),
    vec2(0.715629, 0.999939),
    vec2(0.8493, -0.0485549),
    vec2(0.863582, -0.85229),
    vec2(0.890622, 0.850581),
    vec2(0.898068, 0.633778),
    vec2(0.92053, -0.355693),
    vec2(0.933348, -0.62981),
    vec2(0.95294, 0.156896)
);
