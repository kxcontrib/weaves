#include <string>
#include <iostream>
#include <vector>
#include <iterator>

#include <algorithm>

namespace test1 {
  int main(int argc, char *argv[]) {
    std::cerr << "Hello world!" << std::endl;
    return(0);
  }
}

namespace test2 {
  using namespace std;
  
  int main(int argc, char *argv[]) {
    vector<int> V;
    V.push_back(1);
    V.push_back(4);
    V.push_back(2);
    V.push_back(8);
    V.push_back(5);
    V.push_back(7);

    copy(V.begin(), V.end(), ostream_iterator<int>(cout, " "));
    cout << endl;
    // The output is "1 4 2 8 5 7"

    vector<int>::iterator new_end = 
      remove_if(V.begin(), V.end(), bind2nd(equal_to<int>(), 4));
    V.erase(new_end, V.end());

    copy(V.begin(), V.end(), ostream_iterator<int>(cout, " "));
    cout << endl;

    return(0);
  }
}

namespace test3 {
  using namespace std;
  
  int main(int argc, char *argv[]) {
    string s("this is this");
    vector<char> V(s.data(), s.data() + s.length());

    copy(V.begin(), V.end(), ostream_iterator<int>(cout, ","));
    cout << endl;
    // The output is "1 4 2 8 5 7"

    vector<char>::iterator new_end = 
      remove_if(V.begin(), V.end(), bind2nd(equal_to<char>(), 'i'));
    V.erase(new_end, V.end());

    copy(V.begin(), V.end(), ostream_iterator<int>(cout, ","));
    cout << endl;

    string s1(V.begin(), V.end());
    cout << s1 << endl;

    return(0);
  }
}

int main(int argc, char *argv[]) {
  test3::main(argc, argv);

  return(0);
}


