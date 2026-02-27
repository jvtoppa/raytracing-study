module HittableList
using ..CoreVec3: vec3, point3, dot
using ..CoreRay: ray
using ..Hittable: hit_record, HittableAbstract
using ..Sphere: sphere
using CUDA

import ..Sphere: hit
import CUDA: cudaconvert

export hittable_list, hit, push!, empty!

const HittableConcrete = Union{sphere}

mutable struct hittable_list <: HittableAbstract
    objects_gpu::CuArray{HittableConcrete, 1}
end

struct hittable_list_device <: HittableAbstract
    objects::CuDeviceVector{HittableConcrete, 1}
end

hittable_list() = hittable_list(CuArray{HittableConcrete, 1}())

@inline function Base.push!(h::hittable_list, o::HittableConcrete)

    new_objects = CuArray{HittableConcrete, 1}([Vector(h.objects_gpu); o])
    h.objects_gpu = new_objects
    return h
end

@inline function Base.empty!(h::hittable_list)
    h.objects_gpu = CuArray{HittableConcrete, 1}()
    return h
end


@inline function CUDA.cudaconvert(hl::hittable_list)
    return hittable_list_device(cudaconvert(hl.objects_gpu))
end

@inline function hit(hl::hittable_list_device, r::ray, ray_tmin, ray_tmax)::Tuple{Bool, hit_record}
    hit_anything::Bool = false
    rec::hit_record = hit_record()
    closest_so_far = ray_tmax

    for i in 1:length(hl.objects)
        obj = hl.objects[i]
        was_hit, temp_rec = hit(obj, r, ray_tmin, closest_so_far)
        if was_hit
            hit_anything = true
            closest_so_far = temp_rec.t
            rec = temp_rec
        end
    end

    return (hit_anything, rec)
end

end