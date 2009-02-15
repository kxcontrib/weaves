/*! 
@file index.cpp 
@author weaves
@date November 2008
@brief Documentation for qsys.
*/

/*! 

\mainpage qsys

\section intro1 Introduction

 qsys is a suite of scripts and C runtime components to add facilities to the
 q/kdb interpreter.

\section intro2 Features

 qsys provides

 - Setting defaults for q/kdb 
 - Different ways of starting q/kdb using runtime scripts
  -# With an extended runtime environment
  -# Without it
 - An extended runtime environment

 The extended runtime environment provides
 - Loading scripts and tables from a QPATH \ref sys
 - Registering and locating servers using a trader \ref trader
 - Utilities functions for
  -# Operating system interaction \ref os
  -# Table and schema operations \ref sch

 There are some optional C runtime extensions
 - Regular expressions \ref regex0
 - String comparison metrics \ref smet0

\section Dependencies

\subsection shell1 Other programs

 The runtime scripts make use of BASH.

\subsection runtime1 Other development environments

 The C runtime components provide regular expression and it needs 
 either regular expression library: currently, GNU and POSIX libraries
 are supported.

@section doc1 Documentation

  Doxygen documentation is extracted from source code comments.

\section Feedback

  Please send any feedback to the authors.

*/

// Local Variables: 
// mode:text 
// mode:outline-minor 
// outline-regexp: " *\\([A-Za-z]\\|[IVXivx0-9]+\\)\\. *"
// outline-regexp: "^\\(\\\\\\|@\\)\\(sub\\)*\\(section\\|page\\|mainpage\\|paragraph\\)"
// mode:auto-fill 
// fill-column: 75 
// comment-column:50 
// comment-start: "//  "  
// comment-end:"" 
// End: 







