#include "config.h"

#include <string>
#include <vector>
#include <iostream>
#include <algorithm>
#include <iterator>

#include "lex.hh"

namespace {
  using namespace std;

  string remove0(const string & s, char c) {
    vector<char> V(s.c_str(), s.c_str() + s.length());
    vector<char>::iterator e0 =
      remove_if(V.begin(), V.end(), bind2nd(equal_to<char>(), c));
    V.erase(e0, V.end());
    string s0(V.begin(), V.end());
    return s0;
  }

  string replace0(const string & s, char c, char d) {
    vector<char> V(s.c_str(), s.c_str() + s.length());
    replace_if(V.begin(), V.end(), bind2nd(equal_to<char>(), c), d);
    string s0(V.begin(), V.end());
    return s0;
  }
}

/// variety of cleanups.
std::string deR(std::string fname) {
  fname = remove0( fname, '\"');
  fname = remove0( fname, '\'');
  fname = remove0( fname, '`');
  fname = replace0( fname, '.', '_' );
  return fname;
}

/// variety of cleanups.
std::string asclass(std::string fname) {
  size_t i0 = fname.find_first_of(".");
  if (i0 != string::npos) {
    fname.erase(i0);
  }

  fname = replace0( fname, '.', '_' );
  return fname;
}
