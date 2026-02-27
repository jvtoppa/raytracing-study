module Hittable

using ..CoreVec3: vec3, point3, dot
using ..CoreRay: ray
export hit_record, face_normal, HittableAbstract

abstract type HittableAbstract end

Base.@kwdef struct hit_record
    point::point3
    normal::vec3
    t::Float32
    front_face::Bool
end


hit_record() = hit_record(vec3(0f0,0f0,0f0),vec3(0f0,0f0,0f0),-1f0, false)

@inline function face_normal(r::ray, outward_normal::vec3)
    front_face = dot(r.direction, outward_normal) < 0f0
    if front_face
        return (outward_normal, front_face)
        
    end
    return (-outward_normal, front_face)
end


end