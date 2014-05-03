dnl weaves
dnl 
dnl Regular expression and string metrics for q/kdb

dnl This uses gnulib

AC_INIT([q], [0.1.1], [walter.d.eaves@gmail.com], [qsys])
AC_PREREQ(2.59)
AC_CONFIG_SRCDIR([qsys.1])
AC_CONFIG_AUX_DIR([config])
AM_INIT_AUTOMAKE([foreign])

AC_COPYRIGHT([README])

dnl create a config.h file (Automake will add -DHAVE_CONFIG_H)
AM_CONFIG_HEADER(config.h)

AC_SUBST(VERSION)

ISODATE=`date +%Y-%m-%d`
AC_SUBST(ISODATE)

AC_CANONICAL_HOST

dnl Checks for programs.
AC_PROG_INSTALL
AC_PROG_CC
AC_LN_S
AC_PATH_PROG([DOXYGEN], [doxygen])
AC_PATH_PROG([SED], [sed])
AC_PATH_PROG([LATEX], [latex])
AC_PATH_PROG([PDFLATEX], [pdflatex])
AC_PATH_PROG([MAKEINDEX], [makeindex])
AC_PATH_PROG([DVIPS], [dvips])
AC_PATH_PROG([QOXYGEN], [qoxygen])

AC_ARG_WITH([qhomedir],
              AC_HELP_STRING([--with-qhomedir],
               [If enabled, set the QHOME variable to be as given. Otherwise, $libdir/q.]),
              [qhomedir=$withval],
              [qhomedir=$prefix/q])

if test "x$build_cpu" = "xi386"; then
 qcpu=32
elif test "x$build_cpu" = "xi686"; then
 qcpu=32
elif test "x$build_cpu" = "xsparc"; then
 qcpu=32
else
 qcpu=64
fi

echo $host_os | grep linux > /dev/null 2>&1 
if test $? -eq 0; then
   qdirsuffix=l$qcpu
fi

echo $host_os | grep darwin > /dev/null 2>&1 
if test $? -eq 0; then
   qdirsuffix=m$qcpu
fi

echo $host_os | grep solaris > /dev/null 2>&1 
if test $? -eq 0; then
   qdirsuffix=s$qcpu
fi

AC_ARG_WITH([qprogdir],
              AC_HELP_STRING([--with-qprogdir],
               [If enabled, set the QPROG variable to be as given. Otherwise, $qhomedir/$qdirsuffix]),
              [qprogdir=$withval],
              [qprogdir=$qhomedir/$qdirsuffix])

AC_ARG_WITH([qprog],
              AC_HELP_STRING([--with-qprog],
               [If enabled, set the name of the Q executable to be as given. Otherwise, "q"]),
              [qprog=$withval],
              [qprog=q])

dnl Hopefully, we will have the q we want to use on the original PATH
dnl or we will have constructed a PATH using the OS

AC_PATH_PROG([QPROG], [$qprog], [$qprogdir/$qprog], [path = $PATH:$progdir])

if test -n "$QPROG"; then
   qprog=`basename $QPROG`
   qprogdir=`dirname $QPROG`
   qhomedir=`dirname $qprogdir`
fi

AC_SUBST([qhomedir],[$qhomedir])
AC_SUBST([qprogdir],[$qprogdir])
AC_SUBST([qprog],[$qprog])

qtrdrhost=""
AC_ARG_WITH([qtrdrhost],
              AC_HELP_STRING([--with-qtrdrhost],
               [Domain name of the QTRDR host. Otherwise, this host]),
              [qtrdrhost=$withval],
              [])

AC_SUBST([qtrdrhost],[$qtrdrhost])

qtrdrport=15001
AC_ARG_WITH([qtrdrport],
              AC_HELP_STRING([--with-qtrdrport],
               [Domain name of the QTRDR port. Otherwise, port 15001]),
              [qtrdrport=$withval],
              [])

AC_SUBST([qtrdrport],[$qtrdrport])

## Added an add-on directory
AC_ARG_ENABLE([string-metrics],
        [AC_HELP_STRING([--enable-string-metrics],
         [Build the string metrics package (smet) (default disable)] )],
	[smet_build=$enableval])

if test x$smet_build = xyes; then
 if test -d "$srcdir/smet"; then
  AC_CONFIG_SUBDIRS([smet])
 fi
fi

if test -d "$srcdir/qdoc"; then
 AC_CONFIG_SUBDIRS([qdoc])
fi

dnl Checks for libraries.

# No code for this scripting system.

dnl Checks for typedefs, structures, and compiler characteristics.

dnl Checks for library functions.

AC_OUTPUT([Makefile
qsys.lsm
qsys.spec
src/Makefile])

