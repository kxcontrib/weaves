/*
 * This library provides a Q server for R
 *
 * See kx wiki https://code.kx.com/trac/wiki/Cookbook/IntegratingWithR
 */

#include <errno.h>
#include <string.h>
#include <R.h>
#include <Rdefines.h>
#include <Rinternals.h>

#include "../c/k.h"

#include "../c/common.c"
#include "../c/qserver.c"
