/* 
   rtocc - converts R to C for Doxygen

   Copyright (C) 2008 Walter Eaves

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  

*/

#include <iostream>
#include <fstream>
#include <cstdio>
#include <sys/types.h>
#include <getopt.h>
#include "system.h"

#include "lex.hh"
#include <FlexLexer.h>

#define EXIT_FAILURE 1

extern "C" {
  char *xstrdup (char *p);
}

static void usage (int status);

/* The name the program was run with, stripped of any leading path. */
char *program_name;

/* Option flags and variables */


static struct option const long_options[] =
{
  {"help", no_argument, 0, 'h'},
  {"version", no_argument, 0, 'V'},
  {"debug", no_argument, 0, 'd'},
  {NULL, 0, NULL, 0}
};

static int decode_switches (int argc, char **argv);

using namespace std;

static int debug_ = 0;
char tfilename[256];

int
main (int argc, char **argv)
{
  int i;

  program_name = argv[0];

  i = decode_switches (argc, argv);

  /* do the work */
  strcpy(tfilename, argv[i]);
  ifstream f(argv[i], ifstream::in);
  yyFlexLexer lex(&f, &cout);
  lex.set_debug(debug_);
  lex.yylex();

  exit (0);
}

/* Set all the option flags according to the switches specified.
   Return the index of the first non-option argument.  */

static int
decode_switches (int argc, char **argv)
{
  int c;


  while ((c = getopt_long (argc, argv, 
			   "h"	/* help */
			   "d"	/* debug */
			   "V",	/* version */
			   long_options, (int *) 0)) != EOF)
    {
      switch (c)
	{
	case 'V':
	  printf ("t %s\n", VERSION);
	  exit (0);

	case 'h':
	  usage (0);

	case 'd':
	  debug_ = 1;
	  break;

	default:
	  usage (EXIT_FAILURE);
	}
    }

  return optind;
}


static void
usage (int status)
{
  printf (_("%s - \n"), program_name);
  printf (_("Usage: %s [OPTION]... [FILE]...\n"), program_name);
  printf (_("Options:\n"
"  -h, --help                 display this help and exit\n"
"  -V, --version              output version information and exit\n"
));
  exit (status);
}
