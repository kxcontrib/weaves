/* \file egext.c
   \brief Regular expression interface - utility regular expressions for q/kdb using GNUlib

Test program.

\author Walter.Eaves@bigfoot.com

*/

#include "config.h"

#include "stdlib.h"
#include "stdio.h"

#include "time0.h"

int main(int argc, char **argv) {

  {
    unsigned int now0;
    time_t now1;
    struct timeval tv0;

    fprintf(stderr, "sizeof: unsigned int %u time_t %u struct timeval %u\n", sizeof(now0),
	    sizeof(now1), sizeof(tv0));
  }

  unsigned int now0;
  time_t *t0 = time((time_t *)&now0);
  
  time_t now1;
  time_t *t1 = time(&now1);
  
  fprintf(stderr, "time_t 0x%p\n", t1);
  fprintf(stderr, "time_t %u\n", *((unsigned int *)&now1) );

  struct tm now10;
  gmtime_r(&now1, &now10);

  tm0_print(&now10);

  struct timeval tv0;

  int retval = gettimeofday(&tv0, NULL);
  fprintf(stderr, "retval %d\n", retval);
  fprintf(stderr, "tv0.tv_sec: %u; tv0.tv_usec: %u\n", tv0.tv_sec, tv0.tv_usec);

  struct tm now2;
  now2.tm_sec = 0;
  now2.tm_min = 0;
  now2.tm_hour = 0;
  now2.tm_mday = now10.tm_mday;
  now2.tm_mon = now10.tm_mon;
  now2.tm_year = now10.tm_year;
  /* now2.tm_wday = 0; */
  /* now2.tm_yday = 0; */
  now2.tm_isdst = 0;

  time_t now20 = mktime(&now2);

  fprintf(stderr, "now20: %d\n", now20);
  
  {
    int time1[7] = { now10.tm_year, now10.tm_mon, now10.tm_mday,
		     now10.tm_hour, now10.tm_min, now10.tm_sec, 500 };

    double r0 = tm0_tm2utc(time1, 0);
    time_t r1;
    r1 = (time_t) r0;
    fprintf(stderr, "now10: r0: %f; %s\n", r0, ctime(&r1) );
  }

  {
    int time1[7] = { 1900 + now10.tm_year, 1 + now10.tm_mon, now10.tm_mday,
		     now10.tm_hour, now10.tm_min, now10.tm_sec, 500 };

    tm0_empty0(time1);
    double r0 = tm0_tm2utc(time1, 0);
    time_t r1;
    r1 = (time_t) r0;
    fprintf(stderr, "now10: r0: %f; %s\n", r0, ctime(&r1) );
  }

  return 0;
}
