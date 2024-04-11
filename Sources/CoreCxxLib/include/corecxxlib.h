#pragma once

#include <string>
#include <vector>
#include <iostream>

using stdVecInt = std::vector<int>;

inline std::vector<int> getProgramVersion() {
  return {1,2,3};
}

inline int testMe() {
    auto ns = getProgramVersion();
    return ns.size();
}

namespace core {

class Tab {
    std::string name;

public:
    inline Tab() {}
    inline Tab(const std::string &name) : name(name) {}

    inline std::string getName() const {
        return name;
    }
    inline void visitPage(const std::string &page) {
        std::cout << "will go to: " << page << "\n";
    }
};

}
