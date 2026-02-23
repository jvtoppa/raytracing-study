module Sphere

using ..CoreVec3: vec3, point3, dot, -, /, sqrt
using ..CoreRay: ray, at
using ..Hittable: hittable_object, set_face_normal!

export hit_sphere

@inline function hit_sphere(center::vec3, rad::Float32, r::ray, ray_tmin, ray_tmax, hto::hittable_object)
    oc = center - r.origin
    a = dot(r.direction, r.direction)
    half_b = dot(r.direction, oc)
    c = dot(oc, oc) - rad*rad
    
    discriminant = half_b*half_b - a*c
    
    if discriminant < 0f0
        return false
    end
    sqrtdiscriminant = sqrt(discriminant)
    root = (half_b - sqrtdiscriminant) / a
    if root <= ray_tmin || ray_tmax <= root
        root = (half_b + sqrtdiscriminant) / a
        if root <= ray_tmin || ray_tmax <= root
            return false
        end
    end
    hto.t = root
    hto.point = at(root, r)
    hto.normal = (hto.point - center) / rad
    return true
end


end