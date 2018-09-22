cpp!{{
    #include <stdio.h>
    #include <chrono>
}}

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