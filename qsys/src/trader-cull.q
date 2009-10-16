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

// The trader handle.
tr: @[hopen;.trdr.s;`fail]
if[ -11h = type tr;
   (2 ("failed to contact trader on", (string .trdr.s)));
   .sys.exit 1 ];

// The offers at the trader
offers:tr ".trdr.offers"

// A list of the servers to terminate.
servers:select from offers where ttype <> `trdr

// The list of types we will be terminating.
// @note
// If no -type argument given then all types are used.
ttypes: $[not .sys.is_arg`type;
	  distinct value servers[;`ttype];
	  { `$x } each (.sys.arg`type) ]

servers: exec (n;s) from servers where ttype in ttypes

servers:flip servers

// Invoke the cmd (usually exit[0]) on the server named by x.
operator: { [x;cmd]
	   tsym: hsym x;
	   th: @[hopen;tsym;`failed];
	   if[.sys.is_arg`verbose; 0N!("list: ";th; x; cmd)];
	   if[-11h = type th; : ::];
	   if[.sys.is_arg`nodo; : ::];
	   if[.sys.is_arg`verbose; 0N!("kill: ";th; x; cmd)];
	   if[ -11h <> type @[(th);cmd;`]; hclose th] }

// The operation performed.
{
 operator[x[1]; y];
 if[not .sys.is_arg`nodo; tr(".trdr.withdraw[`",(string x[0]),"]") ];
 }[;".sys.exit[0]"] each servers

if[.sys.is_arg`exit; .sys.exit[0] ]


/  Local Variables: 
/  mode:q 
/  q-prog-args: "-verbose"
/  q-prog-args: "-verbose -type pricing help"
/  q-prog-args: "-nodo -verbose -quiet -autoport -type folios"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
