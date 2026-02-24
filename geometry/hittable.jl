module Hittable
using ..CoreVec3: vec3, point3, dot
using ..CoreRay: ray

export hit_record, set_face_normal!, push!, HittableAbstract

abstract type HittableAbstract end

Base.@kwdef mutable struct hit_record
    point::point3
    normal::vec3
    t::Float32
    front_face::Bool
end

hit_record() = hit_record(vec3(0f0,0f0,0f0),vec3(0f0,0f0,0f0),-1f0, false)

@inline function set_face_normal!(r::ray, outward_normal::vec3, hto::hit_record)
    hto.front_face = dot(r.direction, outward_normal) < 0
    if hto.front_face
        hto.normal = outward_normal
        return
    end
    hto.normal = -outward_normal
end






end