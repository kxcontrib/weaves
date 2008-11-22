// weaves
// My site system functions

\d .os

path_sep:enlist("/")
paths_sep:enlist(":")

directory:{ @[{ system("test -d ", x); x }; x; string` ] }
file:{ @[{ system("test -f ", x); x }; x; string` ] }

extant: { [functor; paths]
	  functor each paths @ where { 0 < count x } each functor each paths }

\d .

\d .sys

// List joined with its indices
indexed: { (( til count x ); x ) }

// Set an environment variable QPATH if not already set.
$[0 = count getenv`QPATH; `QPATH setenv (enlist("."),.os.paths_sep,(getenv`QHOME)); ::]

// Implementation for qloader
i.qloader: { [qpaths; tfile] 
	     qpaths:.os.extant[.os.directory; qpaths];
	     qpaths:.os.extant[.os.file;qpaths,\:(.os.path_sep, tfile)];
	     { value ("\\l ", x) } each qpaths; :: }

// Load a file on the QPATH
qloader: { [tfile]
	  QPATH:(getenv`QPATH),.os.paths_sep,(getenv`QHOME);
	  qpaths:":" vs QPATH;
	  .sys.i.qloader[qpaths; tfile] }

// Holder for the command-line args dictionary
i.args: ()

// Put the command-line into a dictionary
args: { .sys.i.args: .Q.opt .z.x; :: }

// Access the value of a command-line argument by symbol
// Returns 1 if present but as no value
arg: { [name]
      $[ (count .sys.i.args) > idx:(key .sys.i.args) ? name;
	$[count v:.sys.i.args @ name; v; 1]; :: ] }

\d .

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

