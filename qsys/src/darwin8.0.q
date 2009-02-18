// @file darwin8.0.q
// @brief My site system functions.
// @author weaves

// \addtogroup logging
// qsys has many functions with logging available. They use the functions
// defined in this module.
// @n
// These default implementations are null. You should load your own with the same
// signatures.
// @{

\d .log

// tracer writes a message and the list of variables.
tracer:{ [m;l] }

// typed writes a message and the list of variables with some type information.
typed:{ [m;l] }

// @}

\d .

// \addtogroup os
// This set of functions tries to provide a uniform interface to the underlying 
// operating system's facilities.
// @note
// Only used on Unix-like systems at the moment.
// @{

\d .os

// @brief The OS path separator.
// You may override this on systems other than Unix, which uses "/"
// @note
// Used by directory() and filen
path_sep:enlist("/")

// @brief The OS paths separator.
// You may override this on systems other than Unix, which uses ":".
// The symbol used to separate paths in an environment variable like QPATH
// and PATH
// @note
// Used by directory() and filen
// Used by qloader()
paths_sep:enlist(":")

// @brief Uses echo to expand shell variables.
// This function simply echoes using the system: variables like ~
// are expanded by the underlying shell.
echoer: { [cmd] $[0 < type cmd; raze system("echo ", cmd); ""] }

// @brief Test for a directory.
// Uses echoer() so it can expand shell variables. Returns an empty string on
// failure otherwise expanded name.
directory:{ [str] @[{ system("test -d ", x); x }; .os.echoer[str]; string` ] }

// @brief Test for a file.
// Uses echoer() so it can expand shell variables. Returns an empty string on
// failure otherwise expanded name.
file:{ [str] @[{ system("test -f ", x); x }; .os.echoer[str]; string` ] }

// @brief Applies a function to each path.
// Used with file() and directory(), this only returns the path if the result
// of the function has a count > 0.
extant: { [functor; paths]
	  functor each paths @ where { 0 < count x } each functor each paths }

// @brief The basename of a path.
// Uses path_sep.
basename: { [sym]
	   x: $[ -11h <> type sym; `$sym; sym];
	   raze -1#.os.path_sep vs (string x) }

// @brief The file stem of a path - no directory part, no extension.
// Uses path_sep and basename()
filebase: { raze 1#"." vs .os.basename[x] }

// @brief The file extension of a path.
// Uses basename() and assumes the extension is delimited after "."
fileext: { v:"." vs .os.basename[x];
	  v:$[ 1 < count v; -1#v; enlist("")];
	  raze v }

// @brief The directory part of a path.
// Uses path_sep. It actually returns the path above. It doesn't check
// if the path is a directory or a file.
dirname: { [v] v:.os.path_sep vs v; .os.path_sep sv -1_v }

// @brief error tracking, is_err()
// Convention to .os.i.err to be a symbol with an error.
.os.i.err: null;

// @brief error tracking.
// Convention to .os.i.err to be a symbol with an error.
is_err:{ -11h = (type .os.i.err) }

// @brief a stack of directories.
// Maintained by pushd() and popd()
.os.dirstack:()

// @brief pushes the current directory onto a stack and moves to the directory given.
pushd: { [d] ndir:value"\\pwd";
	.os.i.err: null;
	.os.i.err: @[value;("\\cd ",d); `$("bad dir: ",d) ];
	$[.os.is_err`; .os.dirstack; .os.dirstack,:ndir] }

// @brief pops the last directory off the stack and moves to it.
popd: { [d] if[ 0 = count .os.dirstack; : .os.dirstack];
       d: $[null[d]; 1; d];
       ndir:d#.os.dirstack;
       .os.dirstack:(d)_.os.dirstack;
       value("\\cd ",first ndir) }

\d .

// @}

// \addtogroup sys
// The sys group has most of the functionality. In particular it has qloader.
// @n
// sys builds on os. It makes use of log internally.
// @{

\d .sys

// Some useful biggish prime numbers - http://primes.utm.edu/lists/small/10000.txt
i.primes:(104677 104681 104683 104693 104701 104707 104711 104717 104723 104729);

// Randomly chooses a prime number from i_primes.
primed: { .sys.i.primes[ rand count .sys.i.primes ] }

// Those types that can be loaded.
qtypes:(enlist("k"); enlist("q"); "qdb")

// True if the file extension belongs to the list of the types.
is_type: { [types; tfile]
	 any({ x ~ .os.fileext y }[;tfile] each types) }

// True if the file extension belongs to qtypes.
is_qtype: { [tfile]
	  (.sys.is_type[.sys.qtypes; tfile]) or (0 < count .os.directory[tfile]) }

// True if the file extension is "qdb".
is_qdb: { [tfile] (.os.fileext tfile) ~ "qdb" }

// True if the file is a qtype and exists.
qsource: { [tfile]
	  tfile:.os.echoer tfile;
	  if[not .sys.is_qtype tfile; :enlist("")];
	  if[0 < count .os.file tfile; :tfile];
	  if[0 < count .os.directory tfile; :tfile];
	  enlist("") }

// @brief If a name is undefined.
// Check if the name appears in the context ctx.
undef: { [ctx;name] (count key ctx) = ((key ctx)?name) }

// @brief List joined with its indices.
// Used in this way: show flip .sys.indexed alist
indexed: { (( til count x ); x ) }

// Set an environment variable QPATH if not already set.
$[0 = count getenv`QPATH; `QPATH setenv (enlist("."),.os.paths_sep,(getenv`QHOME)); ::]

// Add a path to the environment variable QPATH.
qpath.add.i: { `QPATH setenv (x,.os.paths_sep,(getenv`QPATH)); }

// Add the current working directry to the environment variable QPATH
qpath.cwd: { t:getenv`PWD; .sys.qpath.add.i t; t }

// @brief A list of files/directories loaded.
// Basenames of files are stored.
i.qloaded: ()

// @Load a <name>.qdb file using filebase as the table name.
// 
// Push and pop the directory, just in case it is relative to
// the initial working directory.
qdb: { [tfile] .os.pushd .sys.i.cwd;
      t:.os.filebase .os.basename tfile;
      th:hsym `$tfile;
      (t;th);
      a:value(t,": get ", .Q.s1 th);
      .os.popd`;
      a }

// @brief Low-level loader - may cache loads.
// 
// Used by qloader. This actually does the loading.
// Echoes a message "loaded" - not under verbose or trace.
i.qload: { [tfile]
	  t:`$(.os.basename tfile);
	  t1:0b;
	  if[ (0 < count .sys.i.qloaded);
	     t1:(.sys.i.qloaded ? t) < (count .sys.i.qloaded);
	     if[t1 and (not .sys.reload); : ::]
	     ];
	  $[.sys.is_qdb tfile; .sys.qdb tfile; value ("\\l ", tfile)];
	  .sys.i.qloaded: $[ (not .sys.reload) and (not t1); .sys.i.qloaded,t; .sys.i.qloaded ];
	  0N!("loaded: ", tfile);
	  t }

// @brief The implementation for qloader
// This function checks if the file is extant on any of the paths.
// If so, the file is loaded.
i.qloader: { [qpaths; tfile] 
	     qpaths:.os.extant[.os.directory; qpaths];
	     qpaths:.os.extant[.os.file;qpaths,\:(.os.path_sep, tfile)];
	     { r:.sys.i.qload x; if[ not null r; :r ] } each distinct qpaths;
	    :: }

// @brief Load one file on the QPATH.
// If the tfile has an absolute path, it is loaded directly.
// If not, it uses the QPATH via i_qloader.
// @note
// Uses logging function if debug.
qloader0: { [tfile]
	   .log.typed ["qloader0: tfile"; tfile];
	   nfile:raze .sys.qsource tfile;
	   $[0 < count nfile;
	     [.sys.i.qload nfile; : ::];
	     [if[0 < count nfile:.os.file tfile;
		 .Q.x:.Q.x,enlist(nfile); : ::]
	      ]
	     ];

	   if[not .sys.is_qtype tfile; : ::];
	   .log.typed ["qloader0:1: tfile"; tfile];

	   QPATH:(getenv`QPATH),.os.paths_sep,(getenv`QHOME);
	   qpaths:":" vs QPATH;
	   .sys.i.qloader[qpaths; tfile] }

// @brief Load a file or directory directly or from the QPATH.
// 
// An enhancement of the "\\l" command. It uses the environment variable
// QPATH to locate the file/directory and loads it.
// @note
// qloader will only load a file once. Use qreloader to load a file 
// a second or further time.
qloader: { [tfiles] .sys.reload:0; .sys.qloader0 each tfiles; }

// @brief Load a file repeatedly.
// Like qloader, but will load a file a second or subsequent time.
qreloader: { [tfiles] .sys.reload:1; 
	    .sys.qloader0 each tfiles;
	    .sys.reload:0; }

// @brief Put the command-line into a dictionary.
// 
// Uses .Q.opt and .z.x to form a dictionary.
// @note
// It will expand command-line filenames using echoer and then add them to
// .Q.x
args: { .sys.i.args: .Q.opt .z.x;
       .Q.x:.os.echoer each .Q.x;
       :: }

// @brief Access the value of a command-line argument by symbol.
// Returns 1 if present but as no value
arg: { [name]
      $[ (count .sys.i.args) > idx:(key .sys.i.args) ? name;
	$[count v:.sys.i.args @ name; v; 1]; :: ] }

// @brief Access the type of a command-line argument by symbol.
// Returns the type of the argument. If no argument, then a type of integer 1.
type_arg: { [name]
	 $[ (count .sys.i.args) > idx:(key .sys.i.args) ? name;
	   $[count v:.sys.i.args @ name; type v; type 1]; type :: ] }

// @brief Returns true if a argument is present on the command-line.
is_arg: { [name] (type null) <> type type_arg name }

// @brief Lowest port for use by Q servers.
i.lowerport:10000
// @brief Highest port for use by Q servers.
i.upperport:65535

// @brief Randomly generate a port.
i.rport: { [n] n:0;
	 while[not n within (.sys.i.lowerport;.sys.i.upperport);
	       n:(rand .sys.i.upperport)];
	 n }

// @brief attempt to open a port.
i.probe: { [n] n1:@[value;("\\p ",(string n)); `]; -11h <> type n1 }

// @brief Randomly attempts to open a port for the server.
//
// If the argument is given, it will try that first. Afterwards, it will try
// random ports.
// @note
// The argument must lie within the port range.
autoport: { [x]
	   if[(not null x);
	      if[(-6h = type x) and ( x >= .sys.i.lowerport) and (x <= .sys.i.upperport);
		 if[.sys.i.probe[x]; : value"\\p"] ];
	      ];
	   x:.sys.i.rport`;
	   while[not .sys.i.probe[x]; x:.sys.i.rport`];
	   x }

// @brief True if a key falls within the set of keys of a table/dictionary.
is_key: { [t;k] ((key t) ? k) < count (key t) }

// @brief A debugging utility from KX.
//
// Does appear in the tutorial from Borror.
zs:{`d`P`L`G`D!(system"d"),v[1 2 3],enlist last v:value x}

\d .

// @}

// \addtogroup sch
// Schema-based manipulation.
// @n
// sch provides utilities for working with schema and tables.
// @{

\d .sch

// Update a table so that the attribute named with the symbol asym is cast to a symbol
a2sym: { [tbl;asym]
	     f: { `$(string first x) };
	     b: (enlist `i)!enlist `i;
	     a: (enlist asym)!enlist (f;asym);
	     ![tbl;();b;a] }


// Make an hsym.
a2hsym:{ [x;y]
	p:":" sv ("";(string x);(string y));
	hsym `$p }

// Select from a table where a name n is in a set of values v, keying on the column k and returning 
// the value in the column c.
a2list: { [tbl;n;v;c;k]
	      c1: ( enlist (in;n;enlist v) );
	      b: (enlist k)!enlist k;
	      a: (enlist c)!enlist ({first x};c);
	      ?[foliotypes;c1;b;a] }

// Update a table so that the attribute named with the symbol asym is cast to a symbol.
// @note
// Equivalent to this 
// @code
// update asym:`$(string first x) asym by i from tbl
// @endcode

a2sym: { [tbl;asym]
	f: { `$(string first x) };
	b: (enlist `i)!enlist `i;
	a: (enlist asym)!enlist (f;asym);
	![tbl;();b;a] }

// Select from a table where a name n is in a set of values v, keying on the column k and returning 
// the value in the column c.
//
// @note
// Equivalent to this
// @code
// select c:{ first x } c by k from tbl where n in v 
// @endcode
// Useful for extracting from a mapping table:
// @code
// tenors:select nvalue by ovalue from foliotypes where name in `tenor
// @endcode
a2mapping: { [tbl;n;v;c;k]
	    c1: ( enlist (in;n;enlist v) );
	    b: (enlist k)!enlist k;
	    a: (enlist c)!enlist ({first x};c);
	    v xcol ?[tbl;c1;b;a] }

// Update a field named by asym in the table tbl, by looking up its
// keyed value in the table ttbl and using the value in the table named
// by the column tvalue.
//
// @note
// Very similar to vlookup.
// @n
// a2remap[tbl;`tenor;values;`nvalue] would be equivalent to 
// @code
// update tenor:{ txf[values;x;`nvalue] } each tenor by i from tbl
// @endcode
// And values:([tenor:`a1`a2] nvalue:`b1`b2)
// The table values would be produced by a2mapping.
a2remap: { [tbl;asym;ttbl;tvalue]
	  f: { txf[y;x;z] };
	  b: (enlist `i)!enlist `i;
	  a: (enlist asym)!enlist (f[;ttbl;tvalue];asym);
	  ![tbl;();0b;a] }

// @brief Generates a file name with the given MIME extension and saves to it.
//
// This is nothing more than a "save" command.
// @note
// The path of the saved file is to the initial current working directory.
t2mime: { [tsym; mime]
	 v:(.sys.i.cwd,.os.path_sep,(string tsym),".",mime);
	 v1:hsym `$v;
	 save v1 }

// @brief Save to a CSV file.
t2csv:t2mime[;"csv"]

// @brief Flips a table: columns become rows.
//
// The table has 1 key. The key's values will become the column headings.
// They should be legal names for columns.
// The keying value is the name to be given to the column that will
// contain the previous column headings.
flipper: { [tbl1;keying]
	  k1:raze value flip key tbl1;
	  v:flip value flip value tbl1;
	  d1:(k1!v);
	  d1[keying]:cols value tbl1;
	  flip d1 }

// @brief Moves the symbols nsyms in syms to the front of the list.
//
// The elements of the list nsyms are moved to the front of the list syms.
// @note
// No checking
l.promote: { [syms; nsyms] .t.msyms:syms;
             { .t.msyms:(.t.msyms _ .t.msyms ? x) } each nsyms;
             a:raze nsyms,.t.msyms;
             a }

// @brief Moves the columns named in the list nsyms to the front of the columns of the table t.
//
// Uses sch_l_promote()
// @note
// No checking
promote: { [nsyms;t] xcols[.sch.l.promote[cols t; nsyms];t] }

// @brief Pad a string x with character c to length y 
overlay:{ [x;y;c] ((y - count x)#enlist(c)),x }

\d .

// @}

// Overrideable function to exit
.sys.exit: { [x] $[.sys.is_arg`halt; ::; exit x ] }

/ Test set
/ `QPATH setenv ".", .os.paths_sep, (getenv`QHOME), .os.paths_sep, "~/void"

/ Test file
/ tfile:"help.q"
/ qpaths:":" vs QPATH
/ qpaths

/  Local Variables: 
/  mode:q 
/  q-prog-args: "-load help.q -nodo -verbose -quiet"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
