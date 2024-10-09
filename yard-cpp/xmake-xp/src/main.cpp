#include <iostream>
#define STB_DS_IMPLEMENTATION
#include "stb_ds.h"
#include <boost/math/quaternion.hpp>
#define SOKOL_IMPL
#include "sokol_time.h"
#include "raylib.h"
#include "Math/GenVector/Quaternion.h"
#include <vector>

using std::vector;

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

    {
        using ROOT::Math::Quaternion;

        Quaternion q4(1, 2, 3, 4);
        Quaternion q5(5, 6, 7, 8);
        Quaternion q6 = q4 * q5;
        std::cout << q6.I() << ", " << q6.J() << ", " << q6.K() << ", " << q6.U() << std::endl; 

    }

    InitWindow(800, 450, "raylib [core] example - basic window");

    while (!WindowShouldClose())
    {
        BeginDrawing();
            ClearBackground(BLACK);
            DrawText("Congrats for your first window!", 100, 200, 38, LIGHTGRAY);
        EndDrawing();
    }

    CloseWindow();

    uint64_t elapsed = stm_since(start);
    std::cout << "elapsed: " << stm_sec(elapsed) << " seconds" << std::endl;
    return 0;
}
