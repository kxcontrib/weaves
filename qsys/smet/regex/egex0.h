#if !defined(EGEX0_H)
#define EGEX0_H

#include "regex.h" /* Provides regular expression matching */

extern int re1_cc(regex_t *r, const char *p, int icase);
extern int re1_match(const regex_t *r, const char *s, regmatch_t *result);

#define RE1_PUNCT 0
#define RE1_SPACE 1

#define RE1_LAST RE1_SPACE
#define RE1_SIZE RE1_SPACE + 1

extern regex_t * re1_factory(int which);

#endif
