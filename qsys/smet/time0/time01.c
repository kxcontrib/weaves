/** \file egex1.c
   \brief Utility regular expressions for q/kdb using GNUlib

Provide regular expression function for q/kdb.

\author Walter.Eaves@bigfoot.com

*/

#include <config.h>

#include <stdio.h>
#include <stdlib.h>

#include <string.h>

#include <strings.h> /* String utility functions */
#include <errno.h> /* Handle errors */
#include <memory.h> /* Handle errors */

#include "kish.h"
#include "time0.h"

/* #undef NDEBUG */

/** \addtogroup cregex
   C to Q regular expressions
   @{
*/

/* Reduce spaces to one */
K q_re_despace(K str, K opts)
{
  regex_t *regex = 0;
  int err_no;
  char * s;
  regmatch_t result;
  K results;

  int icase = 0;

  re1_err(RE1_NOERR);

  /* One string required */
  if (str->t != 10) return re1_err(RE1_ERR);

  /* Don't free the result */
  if ( !(regex = re1_factory(RE1_SPACE, 0)) )
    return re1_err(RE1_ERR);

  if ( !(s = kstrdup(str)) ) {
    return re1_err(RE1_ERR);
  }

#if !defined(NDEBUG)
  fprintf(stderr, "despace: \"%s\" %d\n", s, strlen(s) );
#endif

  /* Set the ignore case (icase) option */
  if (opts->t == -6 && opts->i == 1)
    icase = REG_ICASE;

  /* This is the bulk of the work */
  while (!re1_match(regex, s, &result, 1, icase)) {
#if !defined(NDEBUG)
  fprintf(stderr, "despace: match: \"%s\" %d %d \n", s, result.rm_so, result.rm_eo);
#endif
    /* Copy last to first + 1 */
    char * p = s + result.rm_eo;
    char * r = s + result.rm_so + 1;
    while (*p) *r++ = *p++;
    *r = '\0';
  }

  results = kpn(s, strlen(s));

  free(s);

  return results;
}

/* Reduce spaces to one */
K q_re_depunct(K str, K opts)
{
  regex_t *regex = 0;
  int err_no;
  char * s;
  regmatch_t result;
  K results;

  int icase = 0;

  re1_err(RE1_NOERR);

  /* One string required */
  if (str->t != 10) return re1_err(RE1_ERR);

  /* Don't free the result */
  if ( !(regex = re1_factory(RE1_PUNCT, 0)) )
    return re1_err(RE1_ERR);

  if ( !(s = kstrdup(str)) ) {
    if (s) free(s);
    return re1_err(RE1_ERR);
  }

  /* Set the ignore case (icase) option */
  if (opts->t == -6 && opts->i == 1)
    icase = REG_ICASE;

  /* This is the bulk of the work */
  while (!re1_match(regex, s, &result, 1, icase)) {
    /* Copy last to first */
    char * p = s + result.rm_eo;
    char * r = s + result.rm_so;
    *r = ' ';
    r++;
    
    while (*p) *r++ = *p++;
    *r = '\0';
  }

  results = kpn(s, strlen(s));

#if !defined(NDEBUG)
  fprintf(stderr, "pair: \"%s\" %d %d \n", s, result.rm_so, result.rm_eo);
#endif
  free(s);

  return results;
}

/** @} */
