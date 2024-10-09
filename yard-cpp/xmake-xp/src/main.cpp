#include <iostream>
#define STB_DS_IMPLEMENTATION
#include "stb_ds.h"
#include <boost/math/quaternion.hpp>
#define SOKOL_IMPL
#include "sokol_time.h"

int main(int argc, char** argv) {
    // use sokol_time
    stm_setup();
    uint64_t start = stm_now();

    // use stb_ds
    int* arr = NULL;
    arrput(arr, 1);
    arrput(arr, 2);
    arrput(arr, 3);

    for (int i = 0; i < arrlen(arr); i++) {
        std::cout << arr[i] << std::endl;
    }

    // use boost quaternion
    boost::math::quaternion<double> q1(1, 2, 3, 4);
    boost::math::quaternion<double> q2(5, 6, 7, 8);
    boost::math::quaternion<double> q3 = q1 * q2;
    std::cout << q3 << std::endl;

    uint64_t elapsed = stm_since(start);
    std::cout << "elapsed: " << stm_sec(elapsed) << std::endl;
    return 0;
}
