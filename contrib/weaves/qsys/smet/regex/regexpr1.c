
/* regexpr.c */
/* Andrew Davison, June 1998, dandrew@ratree.psu.ac.th */


/* Match a regular expression against a string, printing
   a list of matching subexpressions (associated with the
   bracked expressions in the regex). Alternatively, an
   error is printed.

   The output is in Prolog term form, so that it can be
   easily read by a Prolog process.

   The rx library is used, and produces different (more correct)
   output than the regex.h library in most UNIX distributions.
   Rx is an implementation of the standard regular expression matching
   functions specified by POSIX.2 (and then some).

   Rx can be obtained by anonymous FTP from
      ftp://prep.ai.mit.edu/pub/gnu/rx/rx-1.5.tar.gz

   Compilation:
      \gcc -Wall -o regexpr regexpr.c -lrx 

   Usage:
      regexpr "regex" "string-to-match"

   e.g.
      regexpr "a(b)" "abc"
      -->  ok(2).
           reg(0, 2, "ab").
           reg(1, 2, "b").

      regexpr "([^ .]*)\.c" " this is file.c"
      -->  ok(2).
           reg(9, 15, "file.c").
           reg(9, 13, "file").

      regexpr "([[:alpha:]]*)[[:space:]]*([[:alpha:]]*)" "Andrew Davison" 
      -->  ok(3).
           reg(0, 14, "Andrew Davison").
           reg(0, 6, "Andrew").
           reg(7, 14, "Davison").
*/


#include <stdio.h>
#include <stdlib.h>
#include <rxposix.h>        /* rx header */


void report_err(char *fun_nm, int errno, regex_t *rp);
void print_matches(char *tomatch, regmatch_t pmat[], int nsub);


int main(int argc, char *argv[])
{
  char *regex, *tomatch;
  regex_t reg;
  regmatch_t *pmat;
  int errno, nsub;

  if (argc != 3) {
    fprintf(stderr, "Usage: regexpr \"regex\" \"tomatch\"\n");
    exit(1);
  }
  regex = argv[1];
  tomatch = argv[2];

  /* Compile the regular expression; report errors */
  if ((errno = regcomp(&reg, regex, REG_EXTENDED)) != 0) {
    report_err("cmp", errno, &reg);
    exit(0);    /* returning non-0 upsets pclose/1 in BinProlog */
  }

  nsub = reg.re_nsub;
  pmat = (regmatch_t *) malloc(sizeof(regmatch_t)*nsub);

  /* Apply the compiled regular expression against the tomatch string */
  if ((errno = regexec(&reg, tomatch, nsub, pmat, 0)) != 0) {
    report_err("exe", errno, &reg);
    exit(0);   /* returning non-0 upsets pclose/1 in BinProlog */       
  }

  print_matches(tomatch, pmat, nsub);

  regfree(&reg);
  return 0;
}


void report_err(char *fun_nm, int errno, regex_t *rp)
/* Reports an error in Prolog term format:
      err(fun_nm, errno, "errmsg").
   fun_nm is either cmp or exe.
*/
{
  char *errmsg;
  int errlen;

  errlen = (int) regerror(errno, rp, NULL, 0);
  errmsg = (char *) malloc(errlen*sizeof(char));
  regerror(errno, rp, errmsg, errlen);
  printf("err(%s, %d, \"%s\").\n", fun_nm, errno, errmsg);
}


void print_matches(char *tomatch, regmatch_t pmat[], int nsub)
/* Print the matches in a Prolog term format, starting
   with the number of matches:
         ok(nsub).
   Then a line for each matching subexpression:
         reg(start-posn, end-posn, "sub-string").

   start-posn and end-posn are positions in tomatch
*/
{
  int i;

  printf("ok(%d).\n", nsub);
  for (i = 0; i < nsub; i++)
    printf("reg(%d, %d, \"%.*s\").\n", pmat[i].rm_so, pmat[i].rm_eo,
                  pmat[i].rm_eo - pmat[i].rm_so, tomatch + pmat[i].rm_so);
}

