module CoreIO

using ..CoreVec3: color
using ..Camera: RayCamera
export write_file

@inline function write_color(io::IO, pixel_color::color)
    r = pixel_color.x
    g = pixel_color.y
    b = pixel_color.z
    
    rbyte = UInt8(clamp(round(255f0 * r), 0f0, 255f0))
    gbyte = UInt8(clamp(round(255f0 * g), 0f0, 255f0))
    bbyte = UInt8(clamp(round(255f0 * b), 0f0, 255f0))
    
    write(io, rbyte, gbyte, bbyte)
    return
end


@inline function write_file(Camera::RayCamera, framebuf_cpu::Array{color, 1}, show_progress=true)
    open(Camera.image_name, "w") do io
        write(io, "P6\n$(Camera.image_width) $(Camera.image_height)\n255\n")    
        
        total_pixels = length(framebuf_cpu)
        for i in 1:length(framebuf_cpu)
            if show_progress && i % max(1, div(total_pixels, 100)) == 0
                progress = ceil(Int, (i / total_pixels) * 100)
                print("\rWriting: $progress%")
                flush(stdout)
            end
            write_color(io, framebuf_cpu[i])
        end

        if show_progress
        println("\rWriting: 100%")
        end
    end

end


end