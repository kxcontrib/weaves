/* \file egext.c
   \brief Regular expression interface - utility regular expressions for q/kdb using GNUlib

Test program.

\author Walter.Eaves@bigfoot.com

*/

#include "config.h"

#include "stdlib.h"
#include "stdio.h"

#include "egex0.h"

int main(int argc, char **argv) {
  int i;

  i = re1_factory_last();

  printf("regexs %d\n", i);

  void *t = re1_factory(i, "[ ]+$");
  
  return 0;
}
