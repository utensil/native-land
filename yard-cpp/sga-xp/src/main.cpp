#include "ganim/ga/sga.hpp"
#include "ganim/ga/pga3.hpp"
#include "ganim/ga/print.hpp"
#include <iostream>

int main() {
    using namespace ganim::pga3;

    auto v = e1 + e2 + e3;

    std::cout << v << std::endl;

    return 0;
}
