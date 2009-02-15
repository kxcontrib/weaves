// @file commander.q
// @author weaves
// @brief Loadable file invokes a function on a named host and port
//
// commander can be invoked with
// @code
// Qp commander.q -rhost ubu -rport 14901 -hsym :ubu:14901 -cmd .sys.exit 0
// @endcode
// It will invoke sys_exit() on the host on a machine called ubu at port 14901.

// @addtogroup commander
// Contains the commander.q script. This can be used to 
// send a single command to named host on port with -cmd
// Instructs a remote load of a script with -rload.
// It can be passed -rhost, -port or -hsym :host:port to specify the host.
// It supports the switch -async to send the command asynchronously.

// @{

if[.sys.is_arg`verbose; show .sys.i.args]

.t.usage: { [m;v]
	   0N!m;
	   .sys.exit[v] }


if[(not .sys.is_arg`cmd) and (not .sys.is_arg`rload);
   .t.usage["no -cmd or -rload given";1] ]


// @brief Produces the string to send to the remote host.
// 
// It uses sys_qreloader() if --rload was given, otherwise
// the command alone.
.t.cmd: $[.sys.is_arg`rload;
	  (".sys.qreloader"; "enlist"; .Q.s1 first .sys.arg`rload);
	  .sys.arg`cmd ]

// @brief Verifies a host and port were given or an hsym argument.
.t.host: $[not .sys.is_arg`hsym;
	   [ if[not .sys.is_arg`rhost; .t.usage["no -rhost given";1] ];
	    if[not .sys.is_arg`rport; .t.usage["no -rport given";1] ];
	    hsym `$(":", ":" sv (first .sys.arg`rhost;first .sys.arg`rport)) ];
	   `$(first .sys.arg`hsym) ]

if[.sys.is_arg`verbose; show .t.host]

.t.cmd: " " sv .t.cmd

if[.sys.is_arg`verbose; show .t.cmd]

.t.h: @[hopen;.t.host;`failed]

if[-11h = type .t.h; .t.usage[(": " sv ("server not open";string .t.host)); 2] ]

.t.h: $[.sys.is_arg`async; neg .t.h; .t.h]
 
.t.status: @[.t.h;.t.cmd; `$"incomplete call"]

if[not .sys.is_arg`verbose; .t.status]

.t.status

.sys.exit 0

// @}

/  Local Variables: 
/  mode:q 
/  q-prog-args: "-halt -verbose -rhost ubu -rport 14901 -hsym :ubu:14901 -cmd .sys.exit 0"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
