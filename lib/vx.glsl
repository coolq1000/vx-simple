#define MAX_STEP 64
const float VX_VOXEL_SIZE = 100;
const float VX_GRID_SIZE = 8;

struct RayHit {
    bool hit;
    vec4 color;
    vec3 position;
};

vec2 voxel_to_texture(vec3 voxel) {
    float layer = voxel.y;

    vec2 grid = vec2(
        mod(layer, VX_GRID_SIZE),
        floor(layer / VX_GRID_SIZE)
    ) * VX_VOXEL_SIZE;

    return vec2(
        mod(voxel.x, VX_VOXEL_SIZE),
        floor(voxel.z)
    ) + grid;
}

bool voxel_within_bounds(vec3 voxel) {
    // vec2 pos = voxel_to_texture(voxel);
    // return pos.x >= 0.0f && pos.x < 1.0f && pos.y >= 0.0f && pos.y < 1.0f;
    if (voxel.x > 0 && voxel.y > 0 && voxel.z > 0) {
        if (voxel.x < VX_VOXEL_SIZE && voxel.y < VX_VOXEL_SIZE && voxel.z < VX_VOXEL_SIZE) {
            return true;
        }
    }
    return false;
}

RayHit voxel_trace(vec3 origin, vec3 direction, bool sample_first) {
    vec3 camera_offset = fract(cameraPosition);
    origin += camera_offset;

    ivec3 map_pos = ivec3(floor(origin));
    vec3 delta_dist = abs(vec3(length(direction)) / direction);
    ivec3 ray_step = ivec3(sign(direction));

    vec3 side_dist = (sign(direction) * (vec3(map_pos) - origin) + (sign(direction) * 0.5) + 0.5) * delta_dist;
    bvec3 mask;

    for (int s = 0; s < MAX_STEP; s++) {
        if (!sample_first || s != 0) {
            vec3 centered_voxel = map_pos + vec3(VX_VOXEL_SIZE / 2.0f);
            vec2 sample_point = voxel_to_texture(centered_voxel - vec3(1, 0, 1)) / shadowMapResolution;
            if (voxel_within_bounds(centered_voxel) && within_tex(sample_point)) {
                vec4 sample = texture2D(shadowcolor0, sample_point);
                if (texture2D(shadow, sample_point).r < 0.8f) {
                    float dist = length(vec3(mask) * (side_dist - delta_dist)) / length(direction);
                    return RayHit(true, sample, (origin + direction * dist) - camera_offset);
                }
            } else {
                break;
            }
        }
        
        mask = lessThanEqual(side_dist.xyz, min(side_dist.yzx, side_dist.zxy));
        side_dist += vec3(mask) * delta_dist;
        map_pos += ivec3(vec3(mask)) * ray_step;
    }

    return RayHit(false, vec4(0), vec3(0));
}
