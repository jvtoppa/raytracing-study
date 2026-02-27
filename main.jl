using CUDA
include("RayTracer.jl")
using .RayTracer

function main()
    
    camera = RayTracer.setup_camera(
        aspect_ratio = 16.0f0/9.0f0,
        image_width = Int32(1920),
        focal_length = 1.0f0,
        viewport_height = 2.0f0,
        camera_center = RayTracer.vec3(0.0f0, 0.0f0, -2.0f0),
        image_name = "image.ppm"
    )
    world::RayTracer.HittableList.hittable_list = RayTracer.HittableList.hittable_list()
    push!(world, RayTracer.Sphere.sphere(RayTracer.vec3(1.0f0,0.0f0,2.0f0), 1))
    push!(world, RayTracer.Sphere.sphere(RayTracer.vec3(5.0f0,0.0f0,2.0f0), 1))
    push!(world, RayTracer.Sphere.sphere(RayTracer.vec3(3.0f0,0.0f0,2.0f0), 1))
    #world::RayTracer.Sphere.sphere = RayTracer.Sphere.sphere(RayTracer.vec3(0,0,0), 1)
    framebuffer = RayTracer.render_image(camera, world)
    RayTracer.write_file(camera, framebuffer)
    println("\nDone!")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end