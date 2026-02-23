using Base.Threads

struct vec3

    x::Float32
    y::Float32
    z::Float32

end

function Base.:+(v1::vec3, v2::vec3)
    return vec3(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
end

function Base.:-(v1::vec3, v2::vec3)
    return vec3(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
end

function Base.:-(v::vec3)
    return vec3( - v.x, - v.y, - v.z)
end


function Base.:*(v1::vec3, v2::vec3)
    return vec3(v1.x * v2.x, v1.y * v2.y, v1.z * v2.z)
end

function Base.:*(t::Number, v::vec3)
    return vec3(t * v.x, t * v.y, t * v.z)
end

function Base.:*(v::vec3, t::Number)
    return t * v
end

function Base.:/(t::Number, v::vec3)
    return 1/t * v
end

function Base.:/(v::vec3, t::Number)
    return 1/t * v
end


function Base.getindex(v::vec3, i::Int) #one-indexed
    if i == 1
        return v.x
    end
    if i == 2
        return v.y
    end
    if i == 3
        return v.z
    end
    throw(BoundsError(v, i))
end

function length_squared(v::vec3)
    return v[1]^2 + v[2]^2 + v[3]^2
end

function length(v::vec3)
    return sqrt(length_squared(v))
end

function dot(v1::vec3, v2::vec3)
    return v1[1]*v2[1] + v1[2]*v2[2] + v1[3]*v2[3]
end

function cross(v1::vec3, v2::vec3)
    return vec3(v1[2] * v2[3] - v1[3]*v2[2], v1[3]*v2[1] - v1[1]*v2[3], v1[1]*v2[2] - v1[2]*v2[1])
end

function unit_vector(v::vec3)
    return v / length(v)
end

const color = vec3

function write_color(io::IO, pixel_color::color)
    r = pixel_color[1]
    g = pixel_color[2]
    b = pixel_color[3]

    rbyte = UInt8(clamp(round(255*r), 0, 255))
    gbyte = UInt8(clamp(round(255*g), 0, 255))
    bbyte = UInt8(clamp(round(255*b), 0, 255))

    write(io, rbyte, gbyte, bbyte)
    return 1;

end

struct ray

    origin::vec3
    direction::vec3

end

function at(t::Float64, r::ray)
    return r.origin + t*r.direction
end

function hit_sphere(center::vec3, rad::Float64, r::ray)
    oc::vec3 = center - r.origin
    a::Float64 = dot(r.direction, r.direction)
    b::Float64 = -2.0 * dot(r.direction, oc)
    c::Float64 = dot(oc, oc) - rad*rad

    discriminant = b*b - 4*a*c
    if discriminant < 0
        return -1
    
    end
    
    return (- b - sqrt(discriminant)) / (2 * a)

end

function ray_color(r::ray)
    hit = hit_sphere(vec3(0,0,-1), 0.5, r)
    if(hit > 0)
        N = unit_vector(at(hit, r) + vec3(0, 0, 1))
        return 0.5*color(N.x + 1, N.y + 1, N.z + 1)
    end

    unit_direction = unit_vector(r.direction)
    a = 0.5 * (unit_direction[2] + 1.0)
    return (1.0 - a) * vec3(1.0, 1.0, 1.0) + a * vec3(0.5, 0.7, 1.0)
end

function main()
    image_name = "image.ppm"
    aspect_ratio = 16/9
    
    image_width = 1920
    
    image_height = UInt16(trunc(image_width / aspect_ratio))
    if image_height < 1
        image_height = 1
    end

    println("Rendering image \"$image_name\" - $image_width x $image_height")
    focal_length = 1
    viewport_height = 2
    viewport_width = viewport_height * Float64(image_width / image_height)
    camera_center = vec3(0,0,0)
    viewport_u = vec3(viewport_width, 0, 0)
    viewport_v = vec3(0, -viewport_height, 0)
    pixel_delta_u = viewport_u / image_width
    pixel_delta_v = viewport_v / image_height
    viewport_upper_left = camera_center - vec3(0, 0, focal_length) - viewport_u/2 - viewport_v/2;
    pixel00_loc = viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v)

    framebuf = Vector{vec3}(undef, image_height * image_width)
    progress_channel = Channel{Int}(image_height)
    t1 = time()
    Threads.@threads for j = 0:image_height - 1
        @inbounds for i = 0:image_width - 1
            idx = j*image_width + i + 1
            pixel_center = pixel00_loc + (i * pixel_delta_u) + (j * pixel_delta_v)
            ray_direction = pixel_center - camera_center
            r = ray(camera_center, ray_direction)
            framebuf[idx] = ray_color(r)

        end
        put!(progress_channel, 1)
    end

    completed = 0
    while completed < image_height
        take!(progress_channel)
        completed += 1
        print("\r$completed / $image_height")
        flush(stdout)
    end
    println("\nFinished ray calculations. Writing to disk...")

    io = open(image_name, "w")
    write(io, "P6\n$image_width $image_height\n255\n")    
    writing_c = 0
    framebuf_size = image_height*image_width 
    for (i, color) in enumerate(framebuf)
        
        if(i % 100000 == 0)
            progress = ceil(Int, (i / framebuf_size) * 100)
            print("\r$progress %")
            flush(stdout)
        end
        
        write_color(io, color)
    end    
    print("\r100%")
    close(io)
    println("\nFinished rendering.\nTime taken: ", time() - t1)
end
main()