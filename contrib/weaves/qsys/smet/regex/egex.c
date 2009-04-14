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

#include "crc.h"

/** \addtogroup cregex
   C to Q regular expressions
   @{
*/

/* #undef NDEBUG */

/** 
 * Find a location within the string.
 * 
 * @param patt The pattern to compile.
 * @param str The string to search within.
 * @param opts The options to the search.
 * 
 * @return an integer array - first and last position within the string.
 */

K q_re_location1(K patt, K str, K opts)
{
  regex_t * regex;
  int err_no;
  char * p = 0;
  char * s = 0;
  regmatch_t *result;
  K results;
  int nsub = 2; /* has to be at least 2 for POSIX */

  int icase = 0;

  re1_err(RE1_NOERR);

  /* Pair of strings required */
  if ( ! ((patt->t == -6 || patt->t == 10) && str->t == 10) ) 
    return re1_err(RE1_ERR);

  /* Set the ignore case (icase) option */
  if (opts->t == -6 && opts->i == 1)
    icase = REG_ICASE;

  if (!(s = kstrdup(str))) {
    if (s) free(s);
    return re1_err(RE1_ERR);
  }

  if (patt->t == -6) {
    if (!(regex = re1_factory(patt->i, 0)))
      return ki(err_no);
  } else if (patt->t == 10 && !(p = kstrdup(patt))) {
    if (p) free(p);
    return re1_err(RE1_ERR);
  } else {
    /* Make space for the regular expression */
    regex = (regex_t *) malloc(sizeof(regex_t));
    memset(regex, 0, sizeof(regex_t));
    
    if ((err_no = re1_cc(regex, p, icase))) {
      regfree(regex);
      free(regex);
      free(p); free(s);
      return ki(err_no);
    }
  }

#if !defined(NDEBUG)
  fprintf(stderr, "nsub: %d; sizeof(regmatch_t) %d\n", nsub, sizeof(regmatch_t));
#endif
  result = (regmatch_t *) malloc(sizeof(regmatch_t)*nsub);

  results = ktn(KI,2);
  if (re1_match(regex, s, result, nsub, icase)) {
    result[0].rm_so = -1;
    result[0].rm_eo = -1;
  }
  kI(results)[0] = result[0].rm_so;
  kI(results)[1] = result[0].rm_eo;

#if !defined(NDEBUG)
  fprintf(stderr, "pair: sizeof %d %d %d \n", sizeof(result), result[0].rm_so, result[0].rm_eo);
#endif
  if(patt->t != -6) {
    regfree(regex);
    free(regex);
  }
  free(result);

  if (p) free(p);
  if (p) free(s);

  return results;
}

/** Returns a boolean match */
K q_re_location(K patt, K str) {
  return q_re_location1(patt, str, kb(0));
}

/** Returns a boolean match */
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
 * Compile a regular expression pattern.
 * 
 * @param patt The pattern to compile.
 * 
 * @return an integer index into the array that contains the compiled
 * pattern. This is negative if there is no space left in the array.
 */

K q_re_compile(K patt) {
  regex_t * regex;
  char * p;
  int idx;

  re1_err(RE1_NOERR);

  /* Pair of strings required */
  if (patt->t != 10) return re1_err(RE1_ERR);

  if (!(p = kstrdup(patt))) {
    if (p) free(p);
    return re1_err(RE1_ERR);
  }

  idx = re1_factory_last();
  regex = re1_factory(idx, p);

  if(p) free(p);

  return ki(idx);
}

/** 
 * Clear all the cached compiled regular expressions.
 * 
 * @return an integer of the number of patterns freed.
 */

K q_re_reset(K x) {
  return ki(re1_factory_reset());
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

/** 
 * Return a CRC-32 for a string.
 * 
 * @param str string
 * 
 * @return an int
 */

K q_crc32(K str)
{
  char * s;
  K results;
  uint32_t r;

  /* Pair of strings required */
  if (str->t != 10) return re1_err(RE1_ERR);

  if (!(s = kstrdup(str))) {
    if (s) free(s);
    return re1_err(RE1_ERR);
  }

  r = crc32(s, strlen(s));

  results = kj(r);

  return results;
}

/** @} */
