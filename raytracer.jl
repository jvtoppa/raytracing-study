module RayTracer

include("core/vec3.jl")
include("core/ray.jl")

include("geometry/hittable.jl")
include("geometry/sphere.jl")

include("camera/camera.jl")

include("core/io.jl")

include("renderer/kernel.jl")
include("renderer/render.jl")

using .CoreVec3: vec3, point3, color
using .CoreRay: ray
using .Camera: RayCamera, setup_camera
using .Render: render_image
using .CoreIO: write_file

const VERSION = v"0.1.0"


end