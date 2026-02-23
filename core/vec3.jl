module CoreVec3

export vec3, point3, color, +, -, *, /, dot, cross, unit_vector, length_squared, len

struct vec3
    x::Float32
    y::Float32
    z::Float32
end

const color = vec3
const point3 = vec3

@inline function Base.:+(v1::vec3, v2::vec3)
    return vec3(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
end

@inline function Base.:-(v1::vec3, v2::vec3)
    return vec3(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
end

@inline function Base.:-(v::vec3)
    return vec3(-v.x, -v.y, -v.z)
end

@inline function Base.:*(v1::vec3, v2::vec3)
    return vec3(v1.x * v2.x, v1.y * v2.y, v1.z * v2.z)
end

@inline function Base.:*(t::Float32, v::vec3)
    return vec3(t * v.x, t * v.y, t * v.z)
end

@inline function Base.:*(v::vec3, t::Float32)
    return t * v
end

@inline function Base.:/(v::vec3, t::Float32)
    return (1f0/t) * v
end

@inline function length_squared(v::vec3)
    return v.x*v.x + v.y*v.y + v.z*v.z
end

@inline function len(v::vec3)
    return sqrt(length_squared(v))
end

@inline function dot(v1::vec3, v2::vec3)
    return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z
end

@inline function cross(v1::vec3, v2::vec3)
    return vec3(
        v1.y * v2.z - v1.z * v2.y,
        v1.z * v2.x - v1.x * v2.z,
        v1.x * v2.y - v1.y * v2.x
    )
end

@inline function unit_vector(v::vec3)
    return v / len(v)
end

end