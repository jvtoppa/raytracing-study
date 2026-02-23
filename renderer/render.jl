module Render

using CUDA
using ..CoreVec3: vec3, color
using ..Camera: RayCamera, get_pixel_center
using ..Kernel: render_kernel!

function precompile_kernel!(camera::RayCamera)  
    precompile_buf = CuArray{vec3}(undef, 1)
    @cuda threads=(32,16) blocks=(1,1) render_kernel!(
        precompile_buf, Int32(1), Int32(1), 
        camera.pixel00_loc, camera.pixel_delta_u, camera.pixel_delta_v, camera.center
    )
    CUDA.synchronize()
    precompile_buf = nothing
    GC.gc()
    
end

function render_image(camera::RayCamera, threads_x::Int32 = Int32(32), threads_y::Int32 = Int32(16))
    println("Starting render...")
    framebuf = CuArray{vec3}(undef, Int(camera.image_height * camera.image_width))

    threads = (Int32(threads_x), Int32(threads_y))
    blocks_x = Int32(cld(camera.image_width, threads_x))
    blocks_y = Int32(cld(camera.image_height, threads_y))
    blocks = (blocks_x, blocks_y)
    
    t_kernel = time()

    @cuda threads=threads blocks=blocks render_kernel!(
        framebuf, camera.image_width, camera.image_height, 
        camera.pixel00_loc, camera.pixel_delta_u, camera.pixel_delta_v, camera.center
    )
    CUDA.synchronize()
    kernel_time = time() - t_kernel
    println("Kernel execution: $(round(kernel_time * 1000, digits=2)) ms")
    framebuf_cpu = Array(framebuf)

    return framebuf_cpu
end

end