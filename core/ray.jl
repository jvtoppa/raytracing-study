module CoreRay
using ..CoreVec3: vec3, point3, +

export ray, at

Base.@kwdef struct ray
    origin::vec3
    direction::vec3
end

@inline function at(t::Float32, r::ray)
    return r.origin + t * r.direction
end

end