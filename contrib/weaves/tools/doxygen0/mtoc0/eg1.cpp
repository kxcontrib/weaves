
namespace That {
  int f1(int y) {
    return y;
  }
};

int That::f2(int y) {
  return y;
}

namespace Those { int f3(int z) {
  return z;
} }

class This {
  int that;

  int f0(int x) {
    return x;
  }
};
