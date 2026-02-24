module HittableList
using ..CoreVec3: vec3, point3, dot
using ..CoreRay: ray
using ..Hittable: hit_record, HittableAbstract

export hit, hittable_list

Base.@kwdef mutable struct hittable_list <: HittableAbstract

    objects::Vector{HittableAbstract} = Vector{HittableAbstract}()

end

@inline function Base.push!(h::hittable_list, o::HittableAbstract)
    push!(h.objects, o)
end

@inline function Base.empty!(h::hittable_list)
    empty!(h.objects)
end

@inline function hit(hl::hittable_list, r::ray, ray_tmin, ray_tmax, rec::hit_record)
    hit_anything::Bool = false
    temp_rec::hit_record = hit_record()
    closest_so_far = ray_tmax

    for object in hl.objects
        if hit(object, r, ray_tmin, ray_tmax, rec)
            hit_anything = true
            closest_so_far = temp_hto.t
            rec.point = temp_rec.point
            rec.normal = temp_rec.normal
            rec.t = temp_rec.t
            rec.front_face = temp_rec.front_face
            
        end
    end

    return hit_anything
end

end