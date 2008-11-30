/* \file kish.c
   \brief K interfaces

Provide conversion to and from K 

\author Walter.Eaves@bigfoot.com

*/

#include <config.h>

#include <stdio.h>
#include <stdlib.h>

#include <string.h>

#include <errno.h> /* Handle errors */

#include "kish.h"

static K re1_err_;
static K smet1_err_;

/* Error number shared by modules */
/* errors: 0 none, 1 something else */
static int re1_errno = -1;

static int re1_init();
static int smet1_init();

K re1_err(int err_) {
  re1_errno = err_;
  re1_init();
  return re1_err_;
}

K smet1_err(int err_) {
  re1_errno = err_;
  smet1_init();
  return smet1_err_;
}

static int re1_init() {
  static int init_ = 0;

  if (!init_) {
    init_ = 1;

    smet1_err_ = ks(ss("smeterror"));
    smet1_err_ = r1(smet1_err_);

    re1_err_ = ks(ss("regexerror"));
    re1_err_ = r1(re1_err_);

    re1_err(0);
    smet1_err(0);
  }

  return 0;
}

static int smet1_init() {
  re1_init();
}

/* Copy a char array to a string. A problem with zero-length strings */
char *kstrdup(K k1) {
  int tsz=0;
  if (k1->t != 10) return 0;
  tsz = k1->n ? k1->n : 1; 
  return strndup((const char *)kC(k1), (size_t) tsz);
}

