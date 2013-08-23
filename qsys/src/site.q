// @file site.q
// @brief The site file loaded at startup - q.q.
// @author weaves
// The qsys system startup file.
// @note
// This site initialization is only performed if QLOAD is set in the environment.
// @note
// It wry to set .Q.x to contain the data files on the command-line.
// @code
// Qp qfile.q otherfile.csv -arg -args
// @endcode
// It uses .z.x, .z.f and .Q.x

if[0 < count getenv`QLOAD;
   .sys.i.args: .Q.opt .z.x;
   .sys.i.cwd: getenv`PWD;
   value ("\\l ",(getenv`QLOAD));
   if[ 0 > count .z.x;
      .Q.x: $[ "-" <> first first .z.x; enlist first .z.x; .Q.x ] ];
   .sys.args`;

   if[.sys.is_arg`debug; .sys.qloader enlist("log.q"); .log.trace:1];
   // Pops up a message up to say it is verbose.
   if[.sys.is_arg`verbose;
      2 ((";" sv (string .z.Z; string .z.f;"verbose")),enlist("\n"))];
   
   if[.sys.is_arg`verbose; .sys.qloader enlist("help.q")];

   .sys.qpath.cwd`;

   // Extend the qpath if given.
   if[.sys.is_arg`qpath;
      .t.a:.os.absolutely[.sys.i.cwd;] each .sys.arg`qpath;
      .sys.qpath.add.i each .t.a];

   // If autoport is given on the command-line it will call .sys.autoport
   if[.sys.is_arg`autoport; .sys.autoport["I"$first .sys.i.args`autoport] ];

   if[0 < count getenv`QTRDR; .sys.qloader enlist("trdrc.q") ];

   // If a load argument is given, load the script
   if[0 = .sys.type_arg`load; .sys.source:.sys.arg`load; .sys.qloader[.sys.source] ];

   ]

/  Local Variables: 
/  mode:q 
/  q-prog-args: "t.q -nodo -verbose -quiet -qpath $PWD -load help.q"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:

