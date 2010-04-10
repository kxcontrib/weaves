/* 
   rtoc - R to C for doxygen

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

#include <stdio.h>
#include <sys/types.h>
#include <argp.h>
#include "system.h"

#define EXIT_FAILURE 1

#if ENABLE_NLS
# include <libintl.h>
# define _(Text) gettext (Text)
#else
# define textdomain(Domain)
# define _(Text) Text
#endif
#define N_(Text) Text

char *xmalloc ();
char *xrealloc ();
char *xstrdup ();

static error_t parse_opt (int key, char *arg, struct argp_state *state);
static void show_version (FILE *stream, struct argp_state *state);

/* argp option keys */
enum {DUMMY_KEY=129
      ,BRIEF_KEY
      ,DRYRUN_KEY
      ,NOWARN_KEY
      ,CD_KEY
      ,DIRECTORY_KEY
};

/* Option flags and variables.  These are initialized in parse_opt.  */

char *oname;			/* --output=FILE */
FILE *ofile;
char *new_directory;		/* --cd=DIRECTORY */
char *desired_directory;	/* --directory=DIR */
int want_quiet;			/* --quiet, --silent */
int want_brief;			/* --brief */
int want_verbose;		/* --verbose */
int want_dry_run;		/* --dry-run */
int want_no_warn;		/* --no-warn */

static struct argp_option options[] =
{
  { "output",      'o',           N_("FILE"),      0,
    N_("Send output to FILE instead of standard output"), 0 },
  { "quiet",       'q',           NULL,            0,
    N_("Inhibit usual output"), 0 },
  { "silent",      0,             NULL,            OPTION_ALIAS,
    NULL, 0 },
  { "brief",       BRIEF_KEY,     NULL,            0,
    N_("Shorten output"), 0 },
  { "verbose",     'v',           NULL,            0,
    N_("Print more information"), 0 },
  { "dry-run",     DRYRUN_KEY,    NULL,            0,
    N_("Take no real actions"), 0 },
  { "no-warn",     NOWARN_KEY,    NULL,            0,
    N_("Disable warnings"), 0 },
  { "cd",          CD_KEY,        N_("DIRECTORY"), 0,
    N_("Change to DIRECTORY before proceeding"), 0 },
  { "directory",   DIRECTORY_KEY, N_("DIR"),       0,
    N_("Use directory DIR"), 0 },
  { NULL, 0, NULL, 0, NULL, 0 }
};

/* The argp functions examine these global variables.  */
const char *argp_program_bug_address = "<weaves@ubu.weaves.dynalias.org>";
void (*argp_program_version_hook) (FILE *, struct argp_state *) = show_version;

static struct argp argp =
{
  options, parse_opt, N_("[FILE...]"),
  N_("R to C for doxygen"),
  NULL, NULL, NULL
};

extern int yylex();

extern FILE *yyin, *yyout;

int
main (int argc, char **argv)
{
  textdomain(PACKAGE);
  argp_parse(&argp, argc, argv, 0, NULL, NULL);

  /* TODO: do the work */
  if ( argc > 1 )
    yyin = fopen( argv[1], "r" );
  else
    yyin = stdin;

  if ( argc > 2 )
    yyout = fopen( argv[2], "w" );
  else
    yyout = stdout;

  yylex();

  exit (0);
}

/* Parse a single option.  */
static error_t
parse_opt (int key, char *arg, struct argp_state *state)
{
  switch (key)
    {
    case ARGP_KEY_INIT:
      /* Set up default values.  */
      oname = "stdout";
      ofile = stdout;
      new_directory = NULL;
      desired_directory = NULL;
      want_quiet = 0;
      want_brief = 0;
      want_verbose = 0;
      want_dry_run = 0;
      want_no_warn = 0;
      break;

    case 'o':			/* --output */
      oname = xstrdup (arg);
      ofile = fopen (oname, "w");
      if (!ofile)
	argp_failure (state, EXIT_FAILURE, errno,
		      _("Cannot open %s for writing"), oname);
      break;
    case 'q':			/* --quiet, --silent */
      want_quiet = 1;
      break;
    case BRIEF_KEY:		/* --brief */
      want_brief = 1;
      break;
    case 'v':			/* --verbose */
      want_verbose = 1;
      break;
    case DRYRUN_KEY:		/* --dry-run */
      want_dry_run = 1;
      break;
    case NOWARN_KEY:		/* --no-warn */
      want_no_warn = 1;
      break;
    case CD_KEY:		/* --cd */
      new_directory = xstrdup (optarg);
      break;
    case DIRECTORY_KEY:		/* --directory */
      desired_directory = xstrdup (optarg);
      break;

    case ARGP_KEY_ARG:		/* [FILE]... */
      /* TODO: Do something with ARG, or remove this case and make
         main give argp_parse a non-NULL fifth argument.  */
      break;

    default:
      return ARGP_ERR_UNKNOWN;
    }

  return 0;
}

/* Show the version number and copyright information.  */
static void
show_version (FILE *stream, struct argp_state *state)
{
  (void) state;
  /* Print in small parts whose localizations can hopefully be copied
     from other programs.  */
  fputs(PACKAGE" "VERSION"\n", stream);
  fprintf(stream, _("Written by %s.\n\n"), "Walter Eaves");
  fprintf(stream, _("Copyright (C) %s %s\n"), "2008", "Walter Eaves");
  fputs(_("\
This program is free software; you may redistribute it under the terms of\n\
the GNU General Public License.  This program has absolutely no warranty.\n"),
	stream);
}
