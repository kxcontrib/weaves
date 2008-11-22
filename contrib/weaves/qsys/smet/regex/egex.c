/* \file egex.c
   \brief Regular expressions for q/kdb using GNUlib

Provide regular expression function for q/kdb.

\author Walter.Eaves@bigfoot.com

*/

#include <config.h>

#include <stdio.h>
#include <stdlib.h>

#include <errno.h> /* Handle errors */
#include <memory.h> /* Handle errors */

#include "egex0.h"
#include "kish.h"

/* Returns a boolean match */
K q_re_location1(K patt, K str, K opts)
{
  regex_t *regex = 0;
  int err_no;
  char * p;
  char * s;
  regmatch_t result;
  K results;

  int icase = 0;

  re1_err(RE1_NOERR);

  /* Pair of strings required */
  if (patt->t != 10 || str->t != 10) return re1_err(RE1_ERR);

  if (!(p = kstrdup(patt)) || !(s = kstrdup(str)) ) {
    if (p) free(p);
    if (s) free(s);
    return re1_err(RE1_ERR);
  }

  /* Set the ignore case (icase) option */
  if (opts->t == -6 && opts->i == 1)
    icase = REG_ICASE;

  /* Make space for the regular expression */
  regex = (regex_t *) malloc(sizeof(regex_t));
  memset(regex, 0, sizeof(regex_t));

  if ((err_no = re1_cc(regex, p, icase))) {
    regfree(regex); free(regex);
    free(p); free(s);
    return ki(err_no);
  }

  results = ktn(KI,2);
  if (re1_match(regex, s, &result )) {
    result.rm_so = -1;
    result.rm_eo = -1;
  }
  kI(results)[0] = result.rm_so;
  kI(results)[1] = result.rm_eo;

#if !defined(NDEBUG)
  fprintf(stderr, "pair: %d %d \n", result.rm_so, result.rm_eo);
#endif
  regfree(regex); free(regex);
  free(p); free(s);

  return results;
}

/* Returns a boolean match */
K q_re_location(K patt, K str) {
  return q_re_location1(patt, str, kb(0));
}

/* Returns a boolean match */
K q_match1(K patt, K str, K opts)
{
  K result = q_re_location1(patt, str, opts);
  
  return kb( ! (kI(result)[1] < 0) );
}

K q_match(K patt, K str)
{
  return q_match1(patt, str, kb(0));
}

/** 
 * Get the current cpu frequency by reading /proc/cpuinfo, or -1
 * if there is a problem.
 * 
 * @param x Ignored; required to allow us to bind to this from q.
 * 
 * @return A double wrapped in a K object.
 */

K q_get_first_cpu_frequency(K x)
{
  static double frequency = -1.0;
  return kf(frequency);
}

