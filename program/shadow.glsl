#include "/lib/util.glsl"

#ifdef VSH

attribute vec4 mc_Entity;

out vec3 world_position;
out vec3 normal;
out vec4 gsh_color;
out vec2 gsh_texcoord;
out vec4 entity;

void main() {
    world_position = gl_Vertex.xyz;
    normal = gl_Normal;
    gsh_color = gl_Color;
    gsh_texcoord = gl_MultiTexCoord0.xy;
    entity = mc_Entity;
}

#endif

#ifdef GSH

#include "/lib/vx.glsl"

uniform sampler2D tex;

layout(triangles) in;
layout(points, max_vertices = 1) out;

in vec3 world_position[];
in vec3 normal[];
in vec4 gsh_color[];
in vec2 gsh_texcoord[];
in vec4 entity[];

out vec4 color;

void main() {
    if (int(entity[0].x + 0.5f) == 10000) {
        vec3 tri_normal = normalize(cross(world_position[1] - world_position[0], world_position[2] - world_position[0]));
        vec3 tri_centroid = (world_position[0] + world_position[1] + world_position[2]) / 3.0f;
        vec3 within_voxel = tri_centroid + fract(cameraPosition) - tri_normal * 0.1;
        vec3 rounded_voxel = floor(within_voxel);
        vec3 centered_voxel = rounded_voxel + floor(vec3(VX_VOXEL_SIZE / 2.0f));
        if (voxel_within_bounds(centered_voxel)) {
            gl_Position = vec4(voxel_to_texture(centered_voxel) / (shadowMapResolution / 2.0f), 0.0f, 1.0f) - vec4(1, 1, 0, 0);
            vec2 texcoord = (gsh_texcoord[0] + gsh_texcoord[1] + gsh_texcoord[2]) / 3.0f;
            color = ((gsh_color[0] + gsh_color[1] + gsh_color[2]) / 3.0f) * texture2D(tex, texcoord);
            EmitVertex();
            EndPrimitive();
        }
    }
}

#endif

#ifdef FSH

in vec4 color;

void main() {
    /* Shadow colour */
    gl_FragData[0] = color;
}

#endif
