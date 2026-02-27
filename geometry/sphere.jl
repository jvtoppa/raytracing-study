module Sphere

using ..CoreVec3: vec3, point3, dot, -, /, sqrt
using ..CoreRay: ray, at
using ..Hittable: hit_record, face_normal, HittableAbstract

export hit, sphere

Base.@kwdef struct sphere <: HittableAbstract
    
    center::point3
    rad::Float32

end


@inline function hit(obj::sphere, r::ray, ray_tmin, ray_tmax)::Tuple{Bool, hit_record}
    oc = obj.center - r.origin
    a = dot(r.direction, r.direction)
    half_b = dot(r.direction, oc)
    c = dot(oc, oc) - obj.rad*obj.rad
    
    discriminant = half_b*half_b - a*c
    
    if discriminant < 0f0
        return (false, hit_record())
    end
    sqrtdiscriminant = sqrt(discriminant)
    root = (-half_b - sqrtdiscriminant) / a
    if root <= ray_tmin || ray_tmax <= root
        root = (-half_b + sqrtdiscriminant) / a
        if root <= ray_tmin || ray_tmax <= root
            return (false, hit_record())
        end
    end
    p = at(root, r)
    normal = (p - obj.center) / obj.rad
    t, front_face = face_normal(r, normal)
    hto = hit_record(p, t, root, front_face)
    
    return (true, hto)
end


end