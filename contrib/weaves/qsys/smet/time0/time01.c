/** \file time01.c
   \brief POSIX time functions for q/kdb using GNUlib

Provide some UTC support for q/kdb.

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

/**
 * provides the current time in UTC seconds.
 *
 * This is a long. No millisecond accuracy, via the time(2) call.
 *
 * @return long UTC since 1970.01.01T00:00:00.000
 */
K q_utime0(K x) {
  time_t now1;
  time(&now1);
  unsigned int t2 = *((unsigned int *)&now1);

  return kj(t2);
}

/**
 * provides the current time in UTC as a float.
 *
 * This is a float. with microsecond accuracy, via the gettimeofday(2) call.
 *
 * @return float UTC since 1970.01.01T00:00:00.000
 */
K q_utime1(K x) {
  struct timeval tv0;

  if (gettimeofday(&tv0, NULL))
    return kf(-1.0);

  #ifndef NDEBUG
  fprintf(stderr, "tv0.tv_sec: %u; tv0.tv_usec: %u\n", tv0.tv_sec, tv0.tv_usec);
  #endif

  double tv1 = (double) tv0.tv_sec;
  double tv10 = (double) tv0.tv_usec / (double) 1000000.0;
  double tv2 = tv1 + tv10;

  #ifndef NDEBUG
  fprintf(stderr, "tv1: %f; tv10: %f; tv2: %f\n", tv1, tv10, tv2);
  #endif

  return kf(tv2);
}

/**
 * Converts an array of integers into a UTC.
 *
 * The number of integers should be 7 in the order
 * (year;month;day;hour;minute;second;milliseconds)
 * This is a float. with microsecond accuracy, via the gettimeofday(2) call.
 *
 * @return float UTC since 1970.01.01T00:00:00.000
 */
K q_utime2(K x, K opts) {
  if (x->t != 6) return re1_err(RE1_ERR);

  int is_dst = 0;
  if (opts->t == -6) {
    is_dst = (int) opts->s;
  }

  int x0[TM0_N];
  for (int i=0; i < TM0_N; i++)
    x0[i] = 0;

  for (int i=0; i < x->n; i++)
    x0[i] = kI(x)[i];

  tm0_empty0(x0);
  double r0 = tm0_tm2utc(x0, is_dst);

  return kf(r0);
}

static char buffer0[1000];

/**
 * Converts a UTC float back to a string.
 *
 * @note
 * There is a misnomer in the types. q/kdb+ has float and double.
 * Both of these map to the C type double.
 * When interfacing with C only use the x->f type.
 *
 * @return string in format 1970.01.01T00:00:00.000
 */
K q_utime3(K x) {
  if (x->t != -9) return re1_err(RE1_ERR);

  double r0 = x->f;
  int i0 = (int) r0;
  time_t now0 = (time_t) i0;
  ctime_r(&now0, buffer0);

  fprintf(stderr, "ctime: %f %u %s\n", r0, i0, buffer0);

  return ki(0);
}


/** @} */
