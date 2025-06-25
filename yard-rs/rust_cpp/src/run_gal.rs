#![allow(non_upper_case_globals)]

use cpp::cpp;

cpp! {{
    #include <iostream>
    // #include <gal/vga.hpp>
    // #include <gal/pga.hpp>
}}

pub fn hello_pga() {
    unsafe {
        cpp!([] {
            // // Let's work with the projectivized dual space of R3
            // using gal::pga::compute;

            // // We'll specify our points in R^3
            // using point = gal::vga::point<float>;

            // // Let's construct a few random points.
            // // Each of these points occupies no more than 12 bytes (+ alignment padding).
            // point p1{2.4f, 3.6f, 1.3f};
            // point p2{-1.1f, 2.7f, 5.0f};
            // point p3{-1.8f, -2.7f, -4.3f};
        });
    }
}

// cpp!{{
//     #include <iostream>
// }}

pub fn hello() {
    unsafe {
        cpp!([] {
            std::cout << "Hello, World!" << std::endl;
        });
    }
}
