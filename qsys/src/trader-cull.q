/// @file trader-cull.q
/// @author weaves
/// @brief Terminate services using the trader to locate them.
/// 
/// @details 
/// Locate the trader using the well-known port and run remote queries on it.

// @addtogroup commanders Managers
// The trader client trader-cull.q can be used to terminate services listed
// in the trader.
// @{

\d .sch
// A trader client
// Gets offers from the trader and kill everything by a .sys.exit[] command
// @n
// Takes a -type argument that can list the types of the services to kill.
tradercull:()!()
\d .

\T 3

\c 200 400

// The trader handle.
tr: @[hopen;.trdr.s;`fail]
if[ -11h = type tr;
   (2 ("failed to contact trader on", (string .trdr.s)));
   .sys.exit 1 ];

// The offers at the trader
offers:tr ".trdr.offers"
tprops:()

// Not very efficient
tprops: tr $[.sys.is_arg`name; "0!.trdr.tprops"; "0#0!.trdr.tprops" ]
tprops: $[not .sys.is_arg`name; tprops; select from tprops where tname in `$.sys.arg`name ]
tprops: $[not .sys.is_arg`value; tprops; select from tprops where tvalue in `$.sys.arg`value ]

// A list of the servers to terminate.
servers:$[not .sys.is_arg`test; select from offers where ttype <> `trdr; offers]

// The list of types we will be terminating.
// @note
// If no -type argument given then all types are used.
ttypes: $[not .sys.is_arg`type; distinct value servers[;`ttype]; { `$x } each (.sys.arg`type) ]

servers:select from servers where ttype in ttypes

servers:0!servers lj select by n:toffer from tprops

servers: $[not .sys.is_arg`name; servers; select from servers where not null tname ]

.t.cmd1: $[ not .sys.is_arg`cmd1; "\\pwd"; " " sv .sys.arg`cmd1 ]

// Invoke the cmd (usually exit[0]) on the server named by x.
operator: { [x;cmd]
	   tsym: hsym x;
	   th: @[hopen;tsym;`failed];
	   if[.sys.is_arg`verbose; 0N!("list: ";th; x; cmd)];
	   if[-11h = type th; : ::];
	   if[.sys.is_arg`nodo; : ::];
	   if[.sys.is_arg`verbose; 0N!("kill: ";th; x; cmd)];
	   s0: @[(th);cmd;`];
	   s1: @[(th);.t.cmd1;`];
	   if[ -11h <> type s0; hclose th];
	   0N!show s1; 
	   0N!show s0; 
	   :: }

.err.level: $[ .sys.is_arg`list; 1; 0]

.t.cmd: $[ not .sys.is_arg`cmd; ".sys.exit[0]"; " " sv .sys.arg`cmd ]

// The operation performed.
{ [x;y]
 operator[x[1]; y];
 if[.sys.is_arg`verbose; 0N!("offer";x[0]) ]; 
 if[.sys.is_arg`list; .err.level:0; : :: ];
 if[not .sys.is_arg`nodo; tr(".trdr.withdraw[`",(string x[0]),"]") ];
 }[;.t.cmd] each servers[;`n`s];

if[all(.sys.is_arg`exit;not .sys.is_arg`test); .sys.exit[.err.level] ]

if[.sys.is_arg`verbose;0N!("error";.err.level)];

/  Local Variables: 
/  mode:q 
/  q-prog-args: "-verbose"
/  q-prog-args: "-verbose -type pricing help"
/  q-prog-args: "-nodo -verbose -quiet -autoport -type folios"
/  q-prog-args: "-test -nodo -verbose -quiet -autoport -type trdr"
/  q-prog-args: "-test -nodo -verbose -quiet -autoport -type trdr -name pricing -value lxp"
/  q-prog-args: "-exit -test -list -nodo -quiet -autoport -type pricing -name impl -value qsys"
/  q-prog-args: "-verbose -nodo -list -type pricing -name name -value lxp -load trader-cull.q"
/  q-prog-args: "-verbose -list -cmd select count i by date from t -load trader-cull.q"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
