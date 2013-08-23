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

// typed writes a message and the list of variables with some type information.
toc0tic:{ [m] }

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

// @brief Checks if an absolute path - looks for path_sep in first position.
// Used with file() and directory(), this only returns the path if the result
// of the function has a count > 0.

absolute: { [x] all .os.path_sep = 1 # x }

// @brief Marks all paths absolute by pre-pending with a path.
absolutely: { [p;x] a:.os.echoer x;
	     $[.os.absolute a; a; p,.os.path_sep,a] }


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

// Allows one to re-map an hsym. Used by .sch.url
remap: { [ahsym] ahsym }

\d .

// @}

// \addtogroup sys
// The sys group has most of the functionality. In particular it has qloader.
// @n
// sys builds on os. It makes use of log internally.
// @{

\d .sys

// One second as a real
sec1: 2011.04.05T08:00:01.000 - 2011.04.05T08:00:00.000

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
//
// Check if the name appears in the context ctx.
// @note
// Expunge a name from a context is simply
// @code
// delete a from `.
// @endcode
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

qpath.list: { [] QPATH:enlist ".",.os.paths_sep;
	 QPATH:QPATH,.os.paths_sep,.sys.i.cwd;
	 QPATH:(getenv`QPATH),.os.paths_sep,(getenv`QHOME);
	 ":" vs QPATH }

qpath.locate0: { [path0;file0] x:.os.path_sep sv (path0;file0);
		.os.file x }

qpath.locate: { [p;f] a: { t:qpath.locate0[x;y] }[;f] each p;
	       first a where 0 < count each a }

// @brief A list of files/directories loaded.
// Basenames of files are stored.
i.qloaded: ()
// @brief A list of files/directories loaded.
// Full paths of files are stored.
i.qloads: ()

// @Load a <name>.qdb file using filebase as the table name.
// 
// Push and pop the directory, just in case it is relative to
// the initial working directory.
// @note
// A naming problem (no embedded '-') means I have to use a global
// temporary.
qdb: { [tfile] .os.pushd .sys.i.cwd;
      t:.os.filebase .os.basename tfile;
      th:hsym `$tfile;
      (t;th);
      // a:value(t,": get ", .Q.s1 th);
      .tmp.tqdb:get th;
      a:value(t, ":.tmp.tqdb");
      delete tqdb from `.tmp;
      .os.popd`;
      a }

i.abs: { $[.os.absolute x; x; .os.path_sep sv (.sys.i.cwd;x)] }

// @brief Low-level loader - may cache loads.
// 
// Used by qloader. This actually does the loading.
// Echoes a message "loaded" - not under verbose or trace.
// 
// It checks the basename hasn't already been loaded.
i.qload: { [tfile]
	  t:`$(.os.basename tfile);
	  t1:0b;
	  if[ (0 < count .sys.i.qloaded);
	     t1:t in .sys.i.qloaded;
	     if[t1 and (not .sys.reload); : ::]
	     ];
	  a: $[.sys.is_qdb tfile; .sys.qdb tfile; @[value;("\\l ", tfile);`qload] ];
	  if[ not null a ; return : ::];
	  .sys.i.qloaded: $[ (not .sys.reload) and (not t1); .sys.i.qloaded,t; .sys.i.qloaded ];
	  .sys.i.qloads: $[ (not .sys.reload) and (not t1); .sys.i.qloads, enlist .sys.i.abs tfile; .sys.i.qloads ];
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

// @brief Argument trigger - looks for an argument with a matching number.
//
// If the argument is present and has an integer value
// that is true with the function given.
// Stop if a test argument has been given and is greater than 1 (the default).
// @param arg command-line argument to look for
// @param f comparison function
// @param v comparison value
trigger: { [arg; f; v]
	  if[.sys.is_arg[arg];
	     not .sys.type_arg[arg];
	     sarg: @[ { "H"$x }; first .sys.arg[arg]; `$"unint" ];
	     if[ -11h = type sarg; :0b ];
	     : .[f;(sarg;v)] ];
	  0b }


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

// @brief Triggering on a switch on the command-line.
//
// Any of the values with the command-line argument named by ssym returns true.
trigger: { [ssym;f;v]
	  if[not .sys.is_arg ssym; :0b ];
	  arg: .sys.arg ssym;
	  args: $[ 0 > type arg; enlist(string arg); arg];
	  args:{ (type y)$x }[;v] each args;
	  any v f\: args }

<<<<<<< refs/remotes/git-svn
// i.tic: .z.N
// tic0: { [] .sys.i.tic:.z.N }
// toc0: { [] .sys.i.tic: $[ .sys.undef @ `.sys.i`tic; .z.N; .sys.i.tic ];
//       .z.N - .sys.i.tic }

i.tic: 0
tic0: { [] .sys.i.tic:0 }
toc0: { [] .sys.i.tic: $[ .sys.undef @ `.sys.i`tic; .z.N; .sys.i.tic ];
       0 - .sys.i.tic }
=======
>>>>>>> HEAD~0

\d .

// @}

// \addtogroup sch
// Schema-based manipulation.
// @n
// sch provides utilities for working with schema and tables.
// @{

\d .sch

// Return the float of strings like: 04 01234
// @todo
// "I"$"04" does the same.
str2num: { [s] r0:(`short$s) - `short$"0";
	  fx:*[10]; 
	  n0: max ( ((count r0) - 2); 0);
	  n1: reverse [ 1, n0 fx\10 ];
	  (`float$r0) mmu (`float$n1) }

// True is a string begins with a character 
// @todo
// Check for no spaces or punctuation
is_token: { all enlist (first upper 1#string x) within "AZ" }

// Update a table so that the attribute named with the symbol asym is cast to a symbol
a2str: { [tbl;asym]
	f: { string x };
	b: (enlist `i)!enlist `i;
	a: (enlist asym)!enlist (f;asym);
	![tbl;();b;a] }

a2str1: { [tbl;asym]
	b: (enlist `i)!enlist `i;
	a: (enlist asym)!enlist (enlist("");asym);
	![tbl;();b;a] }

// Convert a table's symbols to strings.
t2str: { [tbl]
	.t.tbl:tbl;
	v:exec c from (meta .t.tbl) where t = "s";
	{ .t.tbl::.sch.a2str[.t.tbl;x] } each v;
	v:exec c from (meta .t.tbl) where t = " ";
	{ .t.tbl::.sch.a2str1[.t.tbl;x] } each v;
	.t.tbl }

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

// Make a url from an hsym and a symbol
a2url: { [h;y] a:("http://",(1_string .os.remap[h])); b:("<a href=\"",a,"\">",(string y),"</a>"); `$b }
a2url1: { [h] a:("http://",(1_string .os.remap[h])); `$a }


// Select from a table where a name n is in a set of values v, keying on the column k and 
// returning the value in the column c.
a2list: { [tbl;n;v;c;k]
	 tbl: $[ -11h = type tbl; value string tbl; tbl];
	 c1: ( enlist (in;n;enlist v) );
	 b: $[all null k; 0b; (enlist k)!enlist k];
	 a: (enlist c)!enlist ({first x};c);
	 ?[tbl;c1;b;a] }

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
// a2mapping[foliotypes;`name;`tenor;`nvalue;`ovalue]
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

// Number that are unnull.
//
// Count null values for a column.
// @note
// Can be used to insert records into a count table.
// @n
// @code
// .t.counts: ([] c:(); n:`int$() )
// { `.t.counts insert .t.unnull[tdb05; x] } each cols tdb05
// @endcode
// @note
// The underlying type has to be compatible with the null.

nnull0: { [atbl; asym] 
	  c:enlist ({ [x;y] y x };asym;null);
	  a: (enlist asym)!(enlist(count;asym));
	  r:?[atbl;c;0b;a];
	  (first raze key first r; `int$(first raze value first r)) }

nnull: { [atbl; syms]
	  .t.ncounts: ([] c:(); n:`int$() );
	  syms: $[(any null syms); cols atbl; syms ];
	  { `.t.ncounts insert .sch.nnull0[y; x] }[;atbl] each syms;
	  .t.ncounts }

// @brief Select a key field c from a table tbl where the column n is null
//
// Select fields that have a null value in the column named by n.
// The return values are null
// @param tbl table with a columns n and c
// @return a list of distinct c values
//
// @note
// @code
// a2null[tdb2;`sandpsector;`clientassetid]
// select clientassetid by i from tdb2 where null sandpsector
// @endcode
// @note
// Does not find the keys with a "by"

a2null: { [tbl;n;c]
	 k:`i;
         c1: ( enlist (null;n) );
	 b: (enlist k)!enlist k;
	 a: (enlist c)!enlist ({first x};c);
	 distinct (value ?[tbl;c1;b;a])[c] }

// List the cols in a table except the first n in a table with a prefix
rename: { [l; n; prfx ]
	 m:n#(l);
	 mx:{ `$(y,(string x)) }[;prfx] each (n)_(l);
	 (m, mx) }

// Rename a matching symbol in a list
rename1: { [l;x;y] l[l?x]:y; l }

// Given a table name as a symbol and a string mime type return an hsym.
mimefile: { [tsym;mime;tpath] 
	   tpath: $[ count tpath; tpath; .sys.i.cwd ];
	   v:(tpath,.os.path_sep,(string tsym),".",mime);
	   hsym `$v }

// @brief Generates a file name with the given MIME extension and saves to it.
//
// This is nothing more than a "save" command.
// @note
// The path of the saved file is to the initial current working directory.
t2mime: { [tsym; mime;tpath]
	 v1:.sch.mimefile[tsym;mime;tpath];
	 save v1 }

// @brief Save to a CSV file.
t2csv:t2mime[;"csv";""]
t2csv3:t2mime[;"csv";]

// Convert a table's symbols to strings and save the resulting table.
t2csv2: { [tsym]
	 tbl1:.sch.t2str[value string tsym];
	 v:save mimefile[tsym;"csv"] set tbl1;
	 v }

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

// Using string as an intermediate type, the value of x is cast to that given by y.
// @param x is the input value
// @param y is the type string ("d", "e", "c", "s")
i.cast: { [x;y] $[ y = " "; $[10h = type x; x; string x]; (upper y)$(string x)] }

// Change the type of the column named by asym to the type character given by atype
// in the table tbl.
a2retype: { [tbl;asym;atype] 
	   f: .sch.i.cast[;atype];
	   b: (enlist `i)!enlist `i;
	   a: (enlist asym)!enlist (f;asym);
	   t2: ![tbl;();b;a] }

i.mismatch: { [tbl;rtbl]
	     required0: (cols tbl) where (cols tbl) in (cols rtbl);
	     // Mismatched types
	     f: { [csym;m1;r1]
		 a:m1[csym;`t];
		 b:r1[csym;`t];
		 $[all(a = "C";b=" "); 1b; a = b] };
	     f0: f[;meta tbl;meta rtbl];
	     bad1:required0 where not f0 each required0;
	     flip exec (c;t) from (meta rtbl) where c in bad1 }

t2retype: { [tbl;rtbl]
	   .t.tbl:tbl;
	   bad1:.sch.i.mismatch[tbl;rtbl];
	   { .t.tbl::.sch.a2retype[.t.tbl;x[0];x[1]] } each bad1;
	   .t.tbl }


// Update a table so that the attribute named with the symbol asym is set to the value.
// @note
// If a string is passed, does an enlist using a local function \c f.
// If a null symbol is passed, it is converted to a symbol list.
a2value: { [tbl;asym;tvalue]
	  tvalue: $[ -11h = type tvalue; `symbol$(); tvalue];
	  f: { $[10h = type x; enlist(x); $[ -11h = type x; `symbol$(); x] ] };
	  b: (enlist `i)!enlist `i;
	  a: (enlist asym)!enlist (f;tvalue);
	  ![tbl;();b;a] }

// Return the null value from a table.
// @param csym the symbol for a column name
// @param m1 meta-data from a table: meta tbl
// @return a pair: (csym, null value)
// @note 
// The null value comes from using sch_i_cast()
i.null: { [csym;m1] a:m1[csym;`t];
	 v: $[a = " "; ""; .sch.i.cast[`;a]];
	 (csym; v) }

// Given a reference table rtbl, add missing columns to a named table with a null value
t2required: { [tbl;rtbl]
	     crtbl: $[98h = type rtbl; cols rtbl; rtbl];
	     required0: crtbl where not crtbl in (cols tbl);
	     b:.sch.i.null[;meta rtbl] each required0;
	     .t.tbl:tbl;
	     { .t.tbl::.sch.a2value[.t.tbl;x[0];x[1]] } each b;
	     .t.tbl }

// Given a reference table rtbl, delete columns from the named table that are not in rtbl.
t2unrequired: { [tbl;rtbl]
	       crtbl: $[98h = type rtbl; cols rtbl; rtbl];
	       unrequired0: (cols tbl) where not (cols tbl) in crtbl;
	       ![tbl;();0b;unrequired0] }

t2rematch: { [tbl;rtbl] bad1:.sch.i.mismatch[tbl;rtbl]; }

t.match0: { a:y ss x; $[0 < count a; $[0 = a[0]; (count a; x; y); ()]; :() ] }
t.match1: { [x;y] b:{ a:.sch.t.match0[x; y]; $[ 0 < count a; a; ::] }[;x] each string each y;
	    b:raze b where (1< count each b); b }

t.match: { [x;y] { .sch.t.match1[x;y] }[;y] each string x }

// Return a table of pairs of symbols of names in names.
// @param families symlist of name prefixes.
// @param children symlist of names.
// @return a table
// @note 
// (gro) and (gro0; gro1) would return a table (gro; gro0); (gro; gro1)
// This uses string matching.
familiarize: { [families;children]
	      a:.sch.t.match[families;children];
	      b: ([] f0:(`$a[;1;]); c0:(`$a[;2;]));
	      b }

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
