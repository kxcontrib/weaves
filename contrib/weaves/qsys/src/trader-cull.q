// weaves

/ A trader client

/ Gets offers from the trader and kill everything by a .sys.exit[] command
/ Takes -nodo to not do anything.

tr: @[hopen;.trdr.s;`fail]

if[ -11h = type tr;
   (2 ("failed to contact trader on", (string .trdr.s)));
   .sys.exit 1 ];

offers:tr ".trdr.offers"

servers:exec (n; s) from offers where ttype <> `trdr
servers:flip servers

operator: { [x;cmd]
	   tsym: hsym x;
	   th: @[hopen;tsym;`failed];
	   0N!(th; x; cmd);
	   if[-11h = type th; : ::];
	   if[not .sys.is_arg`nodo;
	      0N!(th; x; cmd);
	      if[ -11h <> type @[(th);cmd;`]; hclose th]
	      ]
	   }

{
 operator[x[1]; y];
 tr(".trdr.withdraw[`",(string x[0]),"]");
 }[;".sys.exit[0]"] each servers

if[.sys.is_arg`exit; .sys.exit[0] ]


/  q-prog-args: "-nodo -verbose -quiet -autoport"

/  Local Variables: 
/  mode:q 
/  q-prog-args: "-verbose"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
