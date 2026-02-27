module Render

using CUDA
using ..CoreVec3: vec3, color, point3
using ..Camera: RayCamera, get_pixel_center
using ..Kernel: render_kernel!
using ..Hittable: HittableAbstract
using ..Sphere: sphere
using ..HittableList: hittable_list, hit, push!, empty!

function precompile_kernel!(camera::RayCamera, dummy::T)  where {T<:HittableAbstract}
    
    precompile_buf = CuArray{vec3}(undef, 1)
    @cuda threads=(32,16) blocks=(1,1) render_kernel!(
        precompile_buf, Int32(1), Int32(1), 
        camera.pixel00_loc, camera.pixel_delta_u, camera.pixel_delta_v, camera.center, dummy
    )
    CUDA.synchronize()
    precompile_buf = nothing
    GC.gc()
    
end

function render_image(camera::RayCamera, world::T, threads_x::Int32 = Int32(32), threads_y::Int32 = Int32(16), verbose::Bool = true) where {T<:HittableAbstract}
    if verbose
        println("Starting render...")
    end
    framebuf = CuArray{vec3}(undef, Int(camera.image_height * camera.image_width))

    threads = (Int32(threads_x), Int32(threads_y))
    blocks_x = Int32(cld(camera.image_width, threads_x))
    blocks_y = Int32(cld(camera.image_height, threads_y))
    blocks = (blocks_x, blocks_y)
    dummy = world
    
    if T <: hittable_list
        dummy = hittable_list() 
        
        push!(dummy, sphere(point3(0,0,0), 0.0001f0))
    end
    if verbose
        println("Precompiling kernel...")
    end
    precompile_kernel!(camera, dummy)
    if verbose
        println("Done. \nRendering kernel...")
    end
    t_kernel = time()

    @cuda threads=threads blocks=blocks render_kernel!(
        framebuf, camera.image_width, camera.image_height, 
        camera.pixel00_loc, camera.pixel_delta_u, camera.pixel_delta_v, camera.center, world
    )
    CUDA.synchronize()
    kernel_time = time() - t_kernel
    
    if verbose
        println("Done. Kernel execution: $(round(kernel_time * 1000, digits=2)) ms")
    end
    framebuf_cpu = Array(framebuf)

    return framebuf_cpu
end

end