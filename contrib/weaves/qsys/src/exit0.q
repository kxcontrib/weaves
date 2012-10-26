// @file exit0.q
// @author weaves
//
// If used at the end of a long sequence of scripts on the -exit -load option 
// then it will exit with error-level zero.
//

if[.sys.is_arg`exit; .sys.exit @ 0]
