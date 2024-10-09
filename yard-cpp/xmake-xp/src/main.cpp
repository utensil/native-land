#include <iostream>
#define STB_DS_IMPLEMENTATION
#include "stb_ds.h"

int main(int argc, char** argv) {
    // use stb_ds
    int* arr = NULL;
    arrput(arr, 1);
    arrput(arr, 2);
    arrput(arr, 3);

    for (int i = 0; i < arrlen(arr); i++) {
        std::cout << arr[i] << std::endl;
    }

    std::cout << "hello world!" << std::endl;
    return 0;
}
