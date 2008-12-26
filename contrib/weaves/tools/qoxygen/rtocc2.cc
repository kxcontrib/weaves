#include "config.h"

#include <string>
#include <iostream>
#include "lex.hh"

#include <iterator>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace boost;

/// variety of cleanups.
string deR(string fname) {
        fname = replace_all_copy( fname, "\"", "" );
        fname = replace_all_copy( fname, "\'", "" );
        fname = replace_all_copy( fname, "`", "" );
        fname = replace_all_copy( fname, ".", "_" );
	return fname;
}

/// variety of cleanups.
string asclass(string fname) {
        replace_first( fname, ".", "" );
        fname = replace_all_copy( fname, ".", "_" );
	return fname;
}
