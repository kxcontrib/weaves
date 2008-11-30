/* \file egex0.c
   \brief Regular expression interface - utility regular expressions for q/kdb using GNUlib

Provide regular expression function for q/kdb.

\author Walter.Eaves@bigfoot.com

*/

#include <config.h>

#include <stdio.h>
#include <stdlib.h>

#include <string.h>

#include "error.h"

#include "egex0.h"

/* #undef NDEBUG */

void strtolower(char *s) {
  for (; *s; s++)
    *s = tolower(*s);
}

static char qbuffer[1024] = "";

char *enquote(const char *s) {
  qbuffer[0] = '\0';
  sprintf(qbuffer, "(%s)", s);
  return qbuffer;
}

/* Compile pattern p to r, return error number as zero on success. */
/* POSIX won't return a location unless you put the whole thing in a pair of brackets */
/* Ignore case doesn't work either, so forced it down */

int re1_cc(regex_t *r, const char *p, int icase) {
  int err_no = -1;
  int flags = REG_EXTENDED | icase;
  char * tbuffer;
  
  tbuffer = enquote(p);

  if (flags & REG_ICASE) {
    strtolower(tbuffer);
  }

  if( (err_no=regcomp(r, tbuffer, flags)) != 0 ) {
    size_t length; 
    char *buffer;

    length = regerror (err_no, r, NULL, 0);
    buffer = malloc(length);
    regerror (err_no, r, buffer, length);
    fprintf(stderr, "regex: %s %d: %s\n", __FILE__, __LINE__, buffer); /* Print the error */
    free(buffer);
  }
  return err_no;
}

struct id_regex_t {
  char spatt[128];
  regex_t * patt;
};

/* problem with quoting square brackets */

static struct id_regex_t regexs[] = {
  { "[!,._;:&/%^£#\"\\{}()+=-]+", 0 },
  { " [ ]+", 0 },
  { "", 0 }, /* end */
  /* attempts */
  { "[^:alnum: ]+", 0 },
  { "", 0 }
};

/* Cached create */
regex_t * re1_factory(int which) {
  regex_t * result = 0;
  int err_no = -1;

  if (which < 0 || which > (RE1_SIZE - 1)) return result;

  /* known */
  if ( (result = regexs[which].patt) ) return result;

  if ( !(result = (regex_t *) malloc(sizeof(regex_t)) ) ) {
    return result = 0;
  }

  if ( (err_no = re1_cc(result, regexs[which].spatt, 0)) ) {
    if (result) free(result); result = 0;
    return result;
  }

  regexs[which].patt = result;

#if !defined(NDEBUG)
    fprintf(stderr, "re1_match: result: %p; spatt %s; err_no %d \n",
	    &regexs[which].patt, regexs[which].spatt, err_no);
#endif

  return re1_factory(which);
}

/* POSIX and GNU have different invocation semantics */

/* This is the POSIX version */

int re1_match(const regex_t *r, const char *s, regmatch_t * result, int len, int flags) {
  size_t no_sub = len; /* length of result */

  if (flags & REG_ICASE) {
    strtolower((char *)s);
  }

#if !defined(NDEBUG)
    fprintf(stderr, "re1_match: %s\n", s);
#endif

  if (regexec(r, s, no_sub, result, 0) == 0) {
#if !defined(NDEBUG)
    fprintf(stderr, "re1_match: %p %p \n", result, &result[0]);
#endif

#if !defined(NDEBUG)
    fprintf(stderr, "re1_match: %d %d \n", result[0].rm_so, result[0].rm_eo);
#endif
    /* Some systems don't reply correctly */
    if (result[0].rm_so > result[0].rm_eo) return 1;
    if (result[0].rm_so > strlen(s) || result[0].rm_so > strlen(s)) return 1;
    return 0;
  }

  return 1;
}

