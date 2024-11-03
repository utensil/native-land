#![allow(non_upper_case_globals)]

use cpp::cpp;

cpp!{{
    #include <iostream>
    // will need to add #include <bit> for clang
    // #include "ganim/ga/sga.hpp"
}}

pub fn hello_pga() {
    unsafe {
        cpp!([] {
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

