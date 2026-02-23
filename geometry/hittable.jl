module Hittable
using ..CoreVec3: vec3, point3
using ..CoreRay: ray

export hittable_object, set_face_normal!

Base.@kwdef mutable struct hittable_object
    point::point3
    normal::vec3
    t::Float32
    front_face::Bool
end

hittable_object() = hittable_object(vec3(0f0,0f0,0f0),vec3(0f0,0f0,0f0),-1f0, false)

@inline function set_face_normal!(r::ray, outward_normal::vec3, hto::hittable_object)
    hto.front_face = dot(r.direction, outward_normal) < 0
    if hto.front_face
        hto.normal = outward_normal
        return
    end
    hto.normal = -outward_normal
end

end