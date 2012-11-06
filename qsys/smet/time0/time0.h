#if !defined(EGEX0_H)
#define EGEX0_H

#include "config.h"

/* Check if using a POSIX regex. */
#if defined(HAVE_REGMATCH_T_RM_SP)
#include "/usr/include/regex.h" 
#else
#include "regex.h"
#endif

/* Check if using time.h */
#if defined(HAVE_TIME_H)
#include "time.h"
#else
#error "no time.h found"
#endif

/* Check if using time.h */
#if defined(HAVE_SYS_TIME_H)
#include "sys/time.h"
#else
#error "no sys/time.h found"
#endif

extern int tm0_print(struct tm *);

/* This takes a 7 integer array, first is a year, last is milliseconds */
#define TM0_N 7
extern double tm0_tm2utc(int *x, int is_dst);
extern int* tm0_empty0(int *x);

extern int re1_cc(regex_t *r, const char *p, int flags);
extern int re1_match(const regex_t *r, const char *s, regmatch_t *result, int len, int flags);

extern void strtolower(char *s);

#define RE1_PUNCT 0
#define RE1_SPACE 1

#define RE1_LAST RE1_SPACE
#define RE1_SIZE RE1_SPACE + 1

extern regex_t * re1_factory(int which, const char *str);
extern int re1_factory_last();
extern int re1_factory_reset();

#endif
