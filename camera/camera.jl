module Camera

using ..CoreVec3: vec3, +, -, *, /

export RayCamera, setup_camera, pixel_deltas, pixel00_loc, get_pixel_center

Base.@kwdef struct RayCamera
    center::vec3
    pixel00_loc::vec3
    pixel_delta_u::vec3
    pixel_delta_v::vec3
    image_width::Int32
    image_height::Int32
    image_name
end

function setup_camera(;
    aspect_ratio::Float32 = 16.0f0/9.0f0,
    image_width::Int32 = Int32(400),
    focal_length::Float32 = 1.0f0,
    viewport_height::Float32 = 2.0f0,
    camera_center::vec3 = vec3(0.0f0, 0.0f0, 0.0f0),
    image_name ="image.ppm"
)
    image_height = Int32(round(image_width / aspect_ratio))
    viewport_width = viewport_height * Float32(image_width) / Float32(image_height)
    
    viewport_u = vec3(viewport_width, 0.0f0, 0.0f0)
    viewport_v = vec3(0.0f0, -viewport_height, 0.0f0)
    
    pixel_delta_u = viewport_u / Float32(image_width)
    pixel_delta_v = viewport_v / Float32(image_height)
    
    viewport_upper_left = camera_center - 
                         vec3(0.0f0, 0.0f0, focal_length) - 
                         viewport_u/2.0f0 - 
                         viewport_v/2.0f0
    pixel00_loc = viewport_upper_left + 0.5f0 * (pixel_delta_u + pixel_delta_v)
    
    return RayCamera(
        camera_center,
        pixel00_loc,
        pixel_delta_u,
        pixel_delta_v,
        image_width,
        image_height,
        image_name
    )
end

@inline function get_pixel_center(camera::RayCamera, i::Int32, j::Int32)
    return camera.pixel00_loc + 
           (Float32(i-1) * camera.pixel_delta_u) + 
           (Float32(j-1) * camera.pixel_delta_v)
end

end