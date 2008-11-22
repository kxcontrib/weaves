// weaves

// Only do this site initialization if QLOAD is set

/ System startup file.
/ Try to set .Q.x to contain otherfile.csv

/ q qfile.q otherfile.csv -arg -args

/ .z.x
/ .z.f
/ .Q.x

if[0 < count getenv`QLOAD;
   .sys.i.args: .Q.opt .z.x;
   .sys.i.cwd: getenv`PWD;
   value ("\\l ",(getenv`QLOAD));
   .sys.args`;

   if[.sys.is_arg`debug; .sys.qloader enlist("log.q"); .log.trace:1];
   // Pop a message up to say it is verbose.
   if[.sys.is_arg`verbose;
      2 ((";" sv (string .z.Z; string .z.f;"verbose")),enlist("\n"))];
   
   .sys.qpath.cwd`;
   .sys.qloader enlist("help.q");

   // If a load argument is given, load the script
   if[0 = .sys.type_arg`load; .sys.source:.sys.arg`load; .sys.qloader[.sys.source] ];
   ]

/  Local Variables: 
/  mode:q 
/  q-prog-args: " -nodo -verbose -quiet -load help.q"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:

