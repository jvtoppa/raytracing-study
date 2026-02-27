module Kernel

using CUDA
using ..CoreVec3: vec3, color, unit_vector, +, -, *, /, point3
using ..CoreRay: ray
using ..Sphere: hit, sphere
using ..Hittable: hit_record, HittableAbstract

@inline function ray_color(r::ray, world::T) where {T<:HittableAbstract}
    rec = hit_record()
    was_hit, rec = hit(world, r, 0f0, typemax(Int32))
    if was_hit
        return 0.5f0 * (rec.normal + color(1f0,1f0,1f0))
    end
    
    unit_direction = unit_vector(r.direction)
    t = 0.5f0 * (unit_direction.y + 1f0)
    
    white = vec3(1f0, 1f0, 1f0)
    blue = vec3(0.5f0, 0.7f0, 1f0)
    
    return vec3(
        (1f0 - t) * white.x + t * blue.x,
        (1f0 - t) * white.y + t * blue.y,
        (1f0 - t) * white.z + t * blue.z
    )
end

function render_kernel!(
    framebuf::CuDeviceArray{vec3, 1},
    image_width::Int32,
    image_height::Int32,
    pixel00_loc::vec3,
    pixel_delta_u::vec3,
    pixel_delta_v::vec3,
    camera_center::vec3,
    world::T) where {T<:HittableAbstract}
    
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y - 1) * blockDim().y + threadIdx().y
    
    if ix <= image_width && iy <= image_height
        idx = (iy - 1) * image_width + ix
        
        pixel_center = pixel00_loc + 
                      (Float32(ix - 1) * pixel_delta_u) + 
                      (Float32(iy - 1) * pixel_delta_v)
        
        ray_direction = pixel_center - camera_center
        r = ray(camera_center, ray_direction)
        
        framebuf[idx] = ray_color(r, world)
    end
    
    return
end

end