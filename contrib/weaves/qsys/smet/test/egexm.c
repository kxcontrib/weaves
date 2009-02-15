/* 
   egex - 

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

   #include <termios.h>
   #include <grp.h>
   #include <pwd.h>
*/

#include "config.h"

#include <string.h>
#include "error.h"
#include "long-options.h"
#include "regex.h"
#include "getopt.h"

#include "stdio.h"

#define EXIT_FAILURE 1

char *xmalloc ();
char *xrealloc ();
char *xstrdup ();

#if !defined(VERSION)
#define VERSION "0.1.0"
#endif


static void usage (int status);

/* The name the program was run with, stripped of any leading path. */
char *program_name;

/* getopt_long return codes */
enum {DUMMY_CODE=129
};

/* Option flags and variables */


static struct option const long_options[] =
  {
    {"help", no_argument, 0, 'h'},
    {"version", no_argument, 0, 'V'},
    {NULL, 0, NULL, 0}
  };

static int decode_switches (int argc, char **argv);

#include "regex/Levenshtein1.h"

static int writer() {
  printf(" Levenshtein_DESC %s\n ",  Levenshtein_DESC );
  printf(" distance_DESC %s\n ",  distance_DESC );
  printf(" ratio_DESC %s\n ",  ratio_DESC );
  printf(" hamming_DESC %s\n ",  hamming_DESC );
  printf(" jaro_DESC %s\n ",  jaro_DESC );
  printf(" jaro_winkler_DESC %s\n ",  jaro_winkler_DESC );
  printf(" median_DESC %s\n ",  median_DESC );
  printf(" median_improve_DESC %s\n ",  median_improve_DESC );
  printf(" quickmedian_DESC %s\n ",  quickmedian_DESC );
  printf(" setmedian_DESC %s\n ",  setmedian_DESC );
  printf(" seqratio_DESC %s\n ",  seqratio_DESC );
  printf(" setratio_DESC %s\n ",  setratio_DESC );
  printf(" editops_DESC %s\n ",  editops_DESC );
  printf(" opcodes_DESC %s\n ",  opcodes_DESC );
  printf(" inverse_DESC %s\n ",  inverse_DESC );
  printf(" apply_edit_DESC %s\n ",  apply_edit_DESC );
  printf(" matching_blocks_DESC %s\n ",  matching_blocks_DESC );
  printf(" subtract_edit_DESC %s\n ",  subtract_edit_DESC );
}

int
main (int argc, char **argv)
{
  int i;

  program_name = argv[0];

  i = decode_switches (argc, argv);

  writer();

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
			   "V",	/* version */
			   long_options, (int *) 0)) != EOF)
    {
      switch (c)
	{
	case 'V':
	  printf ("egex %s\n", VERSION);
	  exit (0);

	case 'h':
	  usage (0);

	default:
	  usage (EXIT_FAILURE);
	}
    }

  return optind;
}


static void
usage (int status)
{
  printf ("%s - \
\n", program_name);
  printf ("Usage: %s [OPTION]... [FILE]...\n", program_name);
  printf ("\
Options:\n\
  -h, --help                 display this help and exit\n\
  -V, --version              output version information and exit\n\
");
  exit (status);
}

/*  gnulib-tool --import error long-options memchr memcpy regex strndup */
