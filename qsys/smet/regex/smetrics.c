/* \file egex.c
   \brief Regular expressions for q/kdb using GNUlib

   Provide regular expression function for q/kdb.

   \author Walter.Eaves@bigfoot.com

*/

#include <config.h>

#include <stdio.h>
#include <stdlib.h>

#include <string.h>
#include "regex.h" /* Provides regular expression matching */

#include <strings.h> /* String utility functions */
#include <errno.h> /* Handle errors */
#include <memory.h> /* Handle errors */

#include "kish.h"

#include "Levenshtein.h"

/* #undef NDEBUG */

static char empty[1] = "";

/* I use a dictionary to pass options. At least two entries in a dictionary:
   one list of keys, one list of values.
   Then the number of keys. */

struct levopts {
  int least;
  int lower;
  int wreplace;
};

static struct levopts call_opts_default = { 0, 0, 0 };
static struct levopts call_opts;

/* Returns an int of number of changes needed */
K c_lev(K str1, K str, K opts, char **hp, char **hs)
{
  char * p;
  char * s;
  K results;
  K* p_k;
  int i;

  smet1_err(SMET1_NOERR);

  /* Pair of strings required */
  if (str1->t != 10 || str->t != 10) return smet1_err(SMET1_ERR);

  if (!(p = kstrdup(str1)) || !(s = kstrdup(str)) ) {
    if (p) free(p);
    if (s) free(s);
    return smet1_err(SMET1_ERR);
  }

#if !defined(NDEBUG)
  fprintf(stderr, "c_lev: %s %s\n", p, s);
#endif

  *hp = p;
  *hs = s;

  call_opts = call_opts_default;

  /* If the options is not a dictionary don't set anything */
  if (opts->t != 99) return kb(1);

#if !defined(NDEBUG)
  fprintf(stderr, "c_lev: dict: count %d type %d type %d\n",
	  opts->n, kK(opts)[0]->t, kK(opts)[1]->t);
#endif

  K keys = kK(opts)[0];
  K values = kK(opts)[1];

  char *sk;
  for (i=0; i<keys->n && !K_NULL( (sk = kS(keys)[i]) ); i++) {
    char *s1 = empty;
    int v = (int )kI(values)[i];

    if (!strcmp(sk, "icase")) {
      if ( (call_opts.lower = v) ) {
	strtolower(p);
	strtolower(s);
      }
    } else if (!strcmp(sk, "least")) {
      if ( (call_opts.least = v) ) {
	int m = strlen(p) < strlen(s) ? strlen(p) : strlen(s) ;
	p[m]=s[m]='\0';
      }
    } else if (!strcmp(sk, "wreplace")) {
      call_opts.wreplace = v;
    }
  }

  return kb(1);
}

/* Returns an int of number of changes needed */
K q_lev_dist(K str1, K str, K opts)
{
  regex_t *regex;
  int err_no = -1;
  char * p;
  char * s;
  K result;
  int icase = 0;

  result = c_lev(str1, str, opts, &p, &s);
  if (result->t != -1) return result;

#if !defined(NDEBUG)
  fprintf(stderr, "lev: %s %s %d \n", p, s, err_no);
#endif

  /* The icase means the replace operation is double cost. */
  if (opts->t == -6 && opts->i == 1)
    icase = 1;

  if (call_opts.wreplace) icase = 1;
#if !defined(NDEBUG)
  fprintf(stderr, "lev: %s %s %d \n", p, s, err_no);
#endif

  err_no = lev_edit_distance(strlen(p), p, strlen(s), s, icase);

#if !defined(NDEBUG)
  fprintf(stderr, "lev: %s %s %d \n", p, s, err_no);
#endif
  free(p); free(s);

  return ki(err_no);
}

/* Returns a float */
K q_lev_ratio(K str1, K str, K opts)
{
  int err_no = -1;
  char * p;
  char * s;
  K result;
  int icase = 0;
  float ratio;
  int lensum = 0;

  result = c_lev(str1, str, opts, &p, &s);
  if (result->t != -1) return result;

#if !defined(NDEBUG)
  fprintf(stderr, "lev: ratio: err_no: %s %s %d \n", p, s, err_no);
#endif

  /* The icase means the replace operation is double cost. */
  if (opts->t == -6 && opts->i == 1)
    icase = 1;

  if (call_opts.wreplace) icase = 1;
#if !defined(NDEBUG)
  fprintf(stderr, "lev: ratio: icase: %s %s %d \n", p, s, icase);
#endif

  err_no = lev_edit_distance(strlen(p), p, strlen(s), s, icase);

  lensum = strlen(p) + strlen(s);
  ratio = ((float) (lensum - err_no)) / ((float) lensum);

#if !defined(NDEBUG)
  fprintf(stderr, "lev: %s %s %d %f\n", p, s, err_no, ratio);
#endif
  free(p); free(s);

  return kf( ratio );
}

/* #undef NDEBUG */

/* Returns a float */
K q_lev_jaro_winkler_ratio(K str1, K str, K opts, K wt)
{
  int err_no = -1;
  char * p;
  char * s;
  K result;
  float icase = ((float) 1)/((float ) 10);
  float ratio;

  result = c_lev(str1, str, opts, &p, &s);
  if (result->t != -1) return result;

#if !defined(NDEBUG)
  fprintf(stderr, "lev: ratio: err_no: %s %s %d \n", p, s, err_no);
#endif

  /* The icase means the replace operation is double cost. */
  if (wt->t == -9 && wt->f != (double )nf && !isnan(wt->f) ) {
    icase = (float) wt->f;
  } else if (wt->t == -8 && wt->e != (float )nf && !isnan(wt->f)) {
    icase = (float) wt->e;
  }

  if (call_opts.wreplace) icase = 1;
#if !defined(NDEBUG)
  fprintf(stderr, "lev: ratio: icase: %s %s %f \n", p, s, icase);
#endif

  ratio = lev_jaro_winkler_ratio(strlen(p), p, strlen(s), s, icase);

#if !defined(NDEBUG)
  fprintf(stderr, "lev: %s %s %d %f\n", p, s, err_no, ratio);
#endif
  free(p); free(s);

  return kf( ratio );
}



