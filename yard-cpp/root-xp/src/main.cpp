// https://stackoverflow.com/a/27443191/200764
#define NOMINMAX
#include <iostream>
#include "Math/GenVector/Quaternion.h"
#include <vector>

using std::vector;

int main(int argc, char** argv) {
    using ROOT::Math::Quaternion;
    
    Quaternion q4(1, 2, 3, 4);
    Quaternion q5(5, 6, 7, 8);
    Quaternion q6 = q4 * q5;
    std::cout << q6.I() << ", " << q6.J() << ", " << q6.K() << ", " << q6.U() << std::endl; 

    return 0;
}
