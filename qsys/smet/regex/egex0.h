#if !defined(EGEX0_H)
#define EGEX0_H

#include "config.h"

/* Check if using a POSIX regex. */
#if defined(HAVE_REGMATCH_T_RM_SP)
#include "/usr/include/regex.h" 
#else
#include "regex.h"
#endif

extern int re1_cc(regex_t *r, const char *p, int flags);
extern int re1_match(const regex_t *r, const char *s, regmatch_t *result, int len, int flags);

extern void strtolower(char *s);

#define RE1_PUNCT 0
#define RE1_SPACE 1

#define RE1_LAST RE1_SPACE
#define RE1_SIZE RE1_SPACE + 1

extern regex_t * re1_factory(int which);

#endif
