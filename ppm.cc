#include <iostream>

int main() {

    // Image

    const int image_width = 256;
    const int image_height = 256;

    int ir = 0;
    int ig = 0;
    int ib = 0;
    // Render

    std::cout << "P3\n" << image_width << ' ' << image_height << "\n255\n";

    for (int j = image_height-1; j >= 0; --j) {
        std::cerr << "\rScanlines remaining: " << j << ' ' << std::flush;
        for (int i = 0; i < image_width; ++i) {
            if (i <= image_height / 2 && j >= (image_height/ 2)){
                int ir = 0;
                int ig = 0;
                int ib = 255;
                
                std::cout << ir << ' ' << ig << ' ' << ib << '\n';
            }
            else if (i >= image_height / 2 && i <= image_height && j <= image_height && j >= (image_height / 2)){
                int ir = 0;
                int ig = 255;
                int ib = 0;
                std::cout << ir << ' ' << ig << ' ' << ib << '\n';
            }
            else if (i > image_height / 2 && j <= (image_height / 2)){
                int ir = 255;
                int ig = 0;
                int ib = 0;
                std::cout << ir << ' ' << ig << ' ' << ib << '\n';
            }
            else {
                int ir = 255;
                int ig = 0;
                int ib = 255;
                std::cout << ir << ' ' << ig << ' ' << ib << '\n';
            }
            
        }
        std::cerr << "\nDone.\n";
    }
}