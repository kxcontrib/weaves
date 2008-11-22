/* \file skel.h

\author Walter.Eaves@bigfoot.com

*/

#ifndef SKEL_H
#define SKEL_H

#include <string.h>

#include "k.h"

extern K re1_err();
#define RE1_ERR 1
#define RE1_NOERR 0

extern K smet1_err();
#define SMET1_ERR 1
#define SMET1_NOERR 0

extern char *kstrdup(K k1);

/* Another bad way to test for a bad pointer */

#define K_NULL(x) ((void *)(x) < (void *)0x8000)

#endif /* not SKEL_H */
