// weaves

/ Service trader - a naming service for Q
/ When an important service appears wants to announce itself, it uses
/ export
/ When a client wants to see if a service is available, it uses the client

/ This is the server implementation
/ It uses a reserved port: 15001
/ It is usually only used remotely

\d .trdr

/ Relatively unique offer identifier
nonce: { [x]
	n:`long$.z.z;
	m:`$(.Q.x12 (n + (2 * rand n) *(2 * rand n) *(2 * rand n) *(2 * rand n) * n));
	$[null x; m; "|" sv (string each (x;m)) ]
	}

/ Reference counted types
ttypes: ( [`symbol$k:()] `symbol$v:(); `int$ni:0N )

/ Basic table: s is an hsym, stype and tprop map to the table
offers0: ([`symbol$n:()] `symbol$s:(); `.trdr.ttypes$ttype:() )

offers: offers0;

/ Table of properties: offer and then name and value
tprops: ( [`.trdr.offers$o:()] `symbol$nm:(); `symbol$vl:() )

/ Add an offer: an hsym, a type and a name-value pair
export0: { [me;t;p]
	 if[ all null value .trdr.ttypes t; insert[`.trdr.ttypes;(t; me;0)] ];
	 n:nonce`;
	 insert[`.trdr.offers;(n;me;t)];
	 .trdr.ttypes:update ni:ni+1 from .trdr.ttypes where k = t;
	 insert[`.trdr.tprops;(n; first p; last p)];
	 n }

export: { [x] .trdr.export0[x[0];x[1];x[2]] }

/ Remove the offer
withdraw: { [offer] 
	   if[ all null value .trdr.offers offer; : offer];
	   0N!("withdraw:"; offer);
	   toffer:.trdr.offers offer;
	   .trdr.tprops:delete from .trdr.tprops where o = offer;
	   .trdr.offers:delete from .trdr.offers where n = offer;
	   .trdr.ttypes:update ni:ni-1 from .trdr.ttypes where k = toffer`ttype;
	   offer }

modify: { [offer;dels;mods] ::: }

query: { [stype;constr;prefs;omax]
	os:exec n from .trdr.offers where ttype = stype;
	if[ not count os; : `.trdr.offers$() ];
	ps:exec o from .trdr.tprops where (o in os) and (nm in constr) and (vl in prefs);
	if[ not count ps; : `.trdr.offers$() ];
	omax#(.trdr.offers flip enlist ps)[`s] }

\d .

.trdr.ttypes,:([k:enlist(`basic)]; v:enlist(`$"Basic service"); ni:0 )
.trdr.ttypes,:([k:enlist(`trdr)]; v:enlist(`$"Trader service"); ni:0 )

.trdr.def.host:.z.h
.trdr.def.port:15001

.trdr.def.s: raze (enlist(":"), ":" sv string each (.trdr.def.host;.trdr.def.port))

.trdr.s: $[ 0 < count getenv`QTRDR; getenv`QTRDR; .trdr.def.s ]

.trdr.t:(":" vs .trdr.s)

/ Check hosts match
if[ (.z.h <> `$.trdr.t[1]); 0N!("trdr: bad host"); .sys.exit 1];

/ Try the port
.trdr.tp1: @[value;("\\p ", .trdr.t[2]);`fail]

if[-11h = type .trdr.tp1; 0N!("trdr: bad port"; .trdr.t[2]; .trdr.tp1); .sys.exit 2];

/ Export myself

ex1:.trdr.export (hsym `$.trdr.s;`trdr;`impl`qsys)

status: { show .trdr.offers; show .trdr.ttypes; show .trdr.tprops; }

remover: { [x] a:select by i from 0!.trdr.offers;
	  a:update hs:{(":" vs (string x))} each s by i from a;
	  a }

.z.pc: { 0N!x }


\

.trdr.s: $[ 0 < count getenv`QTRDR; getenv`QTRDR; .trdr.def.s ]

show .trdr.ttypes
show .trdr.tprops
show .trdr.offers

any not null value .trdr.ttypes `basic

ex1:.trdr.export[hsym `$.trdr.s;`trdr;(`impl;`qsys)]
0N!("export: "; ex1);
ex2:.trdr.export[hsym `$.trdr.s;`folio;(`name;`gro)]
ex3:.trdr.export[hsym `$.trdr.s;`folio;(`name;`dry)]

ex1

show .trdr.ttypes
show .trdr.tprops
show .trdr.offers

0N!("query: "; .trdr.query[`trdr;enlist(`impl); enlist(`qsys);1]);

show .trdr.ttypes
show .trdr.tprops
show .trdr.offers

0N!("query2: "; .trdr.query[`folio;enlist(`name); `gro`dry`eaton;3]);

0N!("withdraw: "; .trdr.withdraw[ex1]);

show .trdr.ttypes
show .trdr.tprops
show .trdr.offers



\

t:`trader
me:hsym `$.trdr.s
if[ null value .trdr.ttypes ttype; insert[`.trdr.ttypes;(t;me)] ];
