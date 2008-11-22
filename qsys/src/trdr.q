// weaves

/ Service trader - a naming service for Q
/ When an important service appears wants to announce itself, it uses
/ export
/ When a client wants to see if a service is available, it uses the client

/ This is the server implementation
/ It uses a reserved port: 15001
/ It is usually only used remotely

\d .trdr

nonce: { [x]
	n:`long$.z.z;
	m:`$(.Q.x12 (n + (2 * rand n) *(2 * rand n) *(2 * rand n) *(2 * rand n) * n));
	$[ not null x; m; "|" sv (string each (x;m)) ]
	}

/ Basic types - at least the type basic
/ tprops - at least the type q/kdb
ttypes: ( [`symbol$k:()] `symbol$v:() )
tprops: ( [`symbol$k:()] `symbol$v:(); `symbol$o:() )

/ Basic table: s is an hsym, stype and tprop map to the table
.i.offers0: ([] `symbol$s:(); `.trdr.ttypes$ttype:(); `.trdr.tprops$tprop:())

.i.offers: .i.offers0;

/ me an hsym, but stype an
export: { [me;t;p]
	 if[ any null value .trdr.ttypes t; insert[`.trdr.ttypes;(t; .trdr.nonce[me])] ];
	 : :: }

withdraw: { [offer] :::}

modify: { [offer;dels;mods] ::: }

query: { [stype;constr;prefs;omax] ::: }

\d .

\d .tradec

export: { [me;ttype;tprop] : :: }

withdraw: { [offer] :::}

modify: { [offer;dels;mods] ::: }

query: { [stype;constr;prefs;omax] ::: }

\d .

.trdr.ttypes,:([k:enlist(`basic)]; v:enlist(`$"Basic service") )
.trdr.ttypes,:([k:enlist(`trdr)]; v:enlist(`$"Trader service") )

.trdr.tprops,:([k:enlist(`$"q/kdb")]; v:enlist(`weaves) )

show .trdr.ttypes
show .trdr.tprops

\p 15001

.trdr.def.host:.z.h
.trdr.def.port:value"\\p"

.trdr.def.s: raze (enlist(":"), ":" sv string each (.trdr.def.host;.trdr.def.port))

.trdr.s: $[ 0 < count getenv`QTRDR; getenv`QTRDR; .trdr.def.s ]

.trdr.i.offers,:([] h:hsym `$.trdr.s; ttype:enlist(`trdr); tprop:enlist(`$("q/kdb")) )

show .trdr.i.offers

null value .trdr.ttypes ? `basic

.trdr.export[hsym `$.trdr.s;`trdr2;`new1]


\

t:`trader
me:hsym `$.trdr.s
if[ null value .trdr.ttypes ttype; insert[`.trdr.ttypes;(t;me)] ];
