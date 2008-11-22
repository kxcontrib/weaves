// weaves
// My site system functions

\d .log

/ Early definition of log methods.

.log.tracer:{ [m;l] }
.log.typed:{ [m;l] }

\d .

\d .os

path_sep:enlist("/")
paths_sep:enlist(":")

echoer: { [cmd] $[0 < type cmd; raze system("echo ", cmd); ""] }

directory:{ @[{ system("test -d ", x); x }; .os.echoer[x]; string` ] }

file:{ @[{ system("test -f ", x); x }; .os.echoer[x]; string` ] }

extant: { [functor; paths]
	  functor each paths @ where { 0 < count x } each functor each paths }

basename: { [sym]
	   x: $[ -11h <> type sym; `$sym; sym];
	   raze -1#.os.path_sep vs (string x) }

filebase: { raze 1#"." vs .os.basename[x] }
fileext: { v:"." vs .os.basename[x];
	  v:$[ 1 < count v; -1#v; enlist("")];
	  raze v }

dirname: { [v] v:.os.path_sep vs v; .os.path_sep sv -1_v }


/ Convention to .os.i.err to be a symbol with an error.
.os.i.err: null;
.os.is_err:{ -11h = (type .os.i.err) }

.os.dirstack:()

pushd: { [d] ndir:value"\\pwd";
	.os.i.err: null;
	.os.i.err: @[value;("\\cd ",d); `$("bad dir: ",d) ];
	$[.os.is_err`; .os.dirstack; .os.dirstack,:ndir] }

popd: { [d] if[ 0 = count .os.dirstack; : .os.dirstack];
       d: $[null[d]; 1; d];
       ndir:d#.os.dirstack;
       .os.dirstack:(d)_.os.dirstack;
       value("\\cd ",first ndir) }

\d .

\d .sys

qtypes:(enlist("k"); enlist("q"); "qdb")

is_type: { [types; tfile]
	 any({ x ~ .os.fileext y }[;tfile] each types) }

is_qtype: { [tfile]
	  (.sys.is_type[.sys.qtypes; tfile]) or (0 < count .os.directory[tfile]) }

is_qdb: { [tfile] (.os.fileext tfile) ~ "qdb" }

qsource: { [tfile]
	  tfile:.os.echoer tfile;
	  if[not .sys.is_qtype tfile; :enlist("")];
	  if[0 < count .os.file tfile; :tfile];
	  if[0 < count .os.directory tfile; :tfile];
	  enlist("") }

// If a name is undefined
undef: { [ctx;name] (count key ctx) = ((key ctx)?name) }

// List joined with its indices
indexed: { (( til count x ); x ) }

// Set an environment variable QPATH if not already set.
$[0 = count getenv`QPATH; `QPATH setenv (enlist("."),.os.paths_sep,(getenv`QHOME)); ::]

qpath.add.i: { `QPATH setenv (x,.os.paths_sep,(getenv`QPATH)); }

qpath.cwd: { t:getenv`PWD; .sys.qpath.add.i t; t }

i.qloaded: ()

/ Load a <name>.qdb file using filebase as the table name.
/ Push and pop the directory, just in case it is relative to
/ the initial working directory.
qdb: { [tfile] .os.pushd .sys.i.cwd;
      t:.os.filebase .os.basename tfile;
      th:hsym `$tfile;
      (t;th);
      a:value(t,": get ", .Q.s1 th);
      .os.popd`;
      a }

// Low-level loader - may cache loads
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

// Implementation for qloader
i.qloader: { [qpaths; tfile] 
	     qpaths:.os.extant[.os.directory; qpaths];
	     qpaths:.os.extant[.os.file;qpaths,\:(.os.path_sep, tfile)];
	     { r:.sys.i.qload x; if[ not null r; :r ] } each distinct qpaths;
	    :: }

// Load a file on the QPATH
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

qloader: { [tfiles] .sys.reload:0; .sys.qloader0 each tfiles; }

qreloader: { [tfiles] .sys.reload:1; 
	    .sys.qloader0 each tfiles;
	    .sys.reload:0; }

// Put the command-line into a dictionary
// Expand command-line files
args: { .sys.i.args: .Q.opt .z.x;
       .Q.x:.os.echoer each .Q.x;
       :: }

// Access the value of a command-line argument by symbol
// Returns 1 if present but as no value
arg: { [name]
      $[ (count .sys.i.args) > idx:(key .sys.i.args) ? name;
	$[count v:.sys.i.args @ name; v; 1]; :: ] }

// Access the value of a command-line argument by symbol
// Returns the type of the argument. If no argument, then a type of integer 1.

type_arg: { [name]
	 $[ (count .sys.i.args) > idx:(key .sys.i.args) ? name;
	   $[count v:.sys.i.args @ name; type v; type 1]; type :: ] }

is_arg: { [name] (type null) <> type type_arg name }

\d .

// Schema-based manipulation

\d .sch

t2mime: { [tsym; mime]
	 v:(.sys.i.cwd,.os.path_sep,(string tsym),".",mime);
	 v1:hsym `$v;
	 save v1 }

t2csv:t2mime[;"csv"]

// Flips a table
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

\d .

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

