#![allow(non_upper_case_globals)]

use cpp::cpp;

cpp!{{
    #include <cstdio>
    #include <chrono>
    #include <iostream>
}}

pub fn hello() {
    unsafe {
        cpp!([] {
            std::cout << "Hello, World!" << std::endl;
        });
    }
}

pub fn printf() {
    unsafe {
        cpp!([] {
            printf("Hello, World!\n");
        });
    }
}

pub fn now() -> i64 {
    unsafe {
        cpp!([] -> i64 as "int64_t" {
            auto now = std::chrono::system_clock::now();
            auto hours_since_epoch = std::chrono::duration_cast<std::chrono::seconds>(
                    now.time_since_epoch());

            return hours_since_epoch.count();
        })
    }
}

pub fn double() {
    unsafe {
        let add = |a : f64, b : f64| {
            cpp!([a as "double", b as "double"] -> f64 as "double" {
                return a + b;
            })
        };

        let times = |a : f64, b : f64| {
            cpp!([a as "double", b as "double"] -> f64 as "double" {
                return a * b;
            })
        };

        let _div = |a : f64, b : f64| {
            cpp!([a as "double", b as "double"] -> f64 as "double" {
                return a / b;
            })
        };

        let check_sum_neq = |a : f64, b : f64, sum : f64| {
            println!("assert {} + {} = {} ≠ {} in both C++ and Rust", a, b, a + b, sum);
            assert_ne!(add(a, b), sum, "in C++");
            assert_ne!(a + b, sum, "in Rust");
        };

        check_sum_neq(0.09, 0.01, 0.1);
        check_sum_neq(0.1, 0.2, 0.3);
        check_sum_neq(0.3, 0.6, 0.9);
        
        // https://en.wikipedia.org/wiki/Floating-point_arithmetic#Accuracy_problems
        {
            let (a, b, c) = (1234.567, 45.67834, 0.0004);

            // floating numbers are not necessarily associative 
            println!("assert ({} + {}) + {} != {} + ({} + {}) in both C++ and Rust", 
                    a, b, c, a, b, c);
            assert_ne!(add(add(a, b), c), add(a, add(b, c)), "in C++");
            assert_ne!((a + b) + c, a + (b + c), "in Rust");
        }
        {
            let (a, b, c) = (1234.567, 1.234567, 3.333333);

            // floating numbers are not necessarily distributive 
            println!("assert ({} + {}) * {} != {} * {} + {} * {} in both C++ and Rust", 
                    a, b, c, a, c, b, c);
            assert_ne!(times(add(a, b), c), add(times(a, c), times(b, c)), "in C++");
            assert_ne!((a + b) * c, a * c + b * c, "in Rust");
        }
        // {
        //     let (a, b, factor) = (63.0, 9.0, 1000.0);
        //     assert_eq!(div(a, b) as i64, 7, "in C++");
        //     assert_eq!((a / b) as i64, 7, "in Rust");

        //     let (a_, b_) = (a / factor, b / factor);
        //     assert_eq!(div(a_, b_) as i64, 6, "in C++");
        //     assert_eq!((a_ / b_) as i64, 6, "in Rust");
        // }
    }
}
