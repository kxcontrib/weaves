// @file trdr.q
// @author weaves
// @brief Service Offer Trader: server implementation

// @addtogroup trader
// The service offer trader is a q/kdb server that keeps a records of the 
// offers of services that are available at each q/kdb server in a system.
// @n
// The \ref tr0 describes the trading service in details. \ref trx explains this
// trader service implementation.
// Using the trading service is described in \ref trx and \ref tri.
// @{

\d .trdr

updt: { [x] servers::servers; props::props; }

// Connections pairings table.
// Connections for auto-withdraw on disconnect
cp:()!()

// Reference counted types.
ttypes: ( [k:`symbol$()] v:`symbol$(); ni:`int$() )

// Table of properties: offer and then name and value
tprops: ( [] toffer:(); tname:(); tvalue:() )
tprops:select by toffer,tname from tprops

// Basic table: s is an hsym, ttype and tprop map to their tables
offers0: ([n:`symbol$()] s:`symbol$(); ttype:`.trdr.ttypes$() )

offers: offers0;

status: { show .trdr.cp; 0N!"offers"; show .trdr.offers; 0N!"types"; show .trdr.ttypes; 0N!"props"; show .trdr.tprops; }

// Add an offer: an hsym, a type and a name-value pair.
// Add an entry to the connection pairings.
i.export: { [me;ptype;p;tnonce]
	   if[ not .sys.is_key[.trdr.ttypes;ptype];
	      insert[`.trdr.ttypes;(ptype; me;0)] ];
	   n: $[null tnonce; .trdr.nonce .z.w; tnonce];
	   0N!("i.export: me;t;p: "; me; (ptype; first p; last p); .z.w );
	   0N!("i.export: n:tnonce"; (n; tnonce) );
	   insert[`.trdr.tprops;(n,p)];
	   insert[`.trdr.offers;(n;me;ptype)];
	   .trdr.ttypes::update ni:ni+1 from .trdr.ttypes where k = ptype;
	   .trdr.cp[n]:.z.w;
	   .trdr.updt`; n }

// Service trader - a naming service for Q.
// When an important service appears wants to announce itself, it uses
// export
// When a client wants to see if a service is available, it uses the client
export: { [x] .trdr.i.export[x[0];x[1];x[2];`] }

// Remove the offer, no need for a list version.
// @note
// The offer key in tprops can't be used to delete with.
withdraw: { [offer] 
	   if[ not .sys.is_key[.trdr.offers;offer]; : offer];
	   toffer:.trdr.offers offer;
	   0N!("withdraw0:"; offer; toffer; .z.w);
	   0N!("withdraw1:"; select from .trdr.tprops where toffer = offer);
	   .trdr.ttypes:update ni:ni-1 from .trdr.ttypes where k in toffer`ttype;
	   delete from `.trdr.offers where n in offer;
	   delete from `.trdr.tprops where toffer in offer;
	   .trdr.updt`; offer }

// Modify is used remotely by a list invocation
i.modify: { [offer;ptype;tprops] 
	   toffer:.trdr.offers offer;
	   0N!("modify1:";offer;ptype;tprops);
	   0N!("modify2:";.trdr.ttypes[ptype];toffer);
	   .trdr.ttypes:update ni:ni-1 from .trdr.ttypes where k in toffer`ttype;
	   if[ not .sys.is_key[.trdr.ttypes;ptype];
	      insert[`.trdr.ttypes;(ptype; toffer`s;0)] ];
	   .trdr.offers:update ttype:ptype from .trdr.offers where n = offer;
	   .trdr.ttypes:update ni:ni+1 from .trdr.ttypes where k = ptype;
	   .trdr.tprops:update tname:first tprops, tvalue:last tprops from .trdr.tprops where toffer = offer;
	   .trdr.updt`; offer }


// List version - I'm hoping that the call on itself enforces locking.
modify: { [x] .trdr.i.modify[ x[0];x[1];x[2] ] }

// Query also has a list invocation
i.query: { [stype;constr;prefs;omax]
	 os:exec n from .trdr.offers where ttype = stype;
	 if[ not count os; : `.trdr.offers$() ];
	 ps:exec toffer from .trdr.tprops where (toffer in os) and (tname in constr) and (tvalue in prefs);
	 if[ not count ps; : `.trdr.offers$() ];
	 offer:omax#(.trdr.offers flip enlist ps)[`s];
	 if[.sys.is_arg`verbose; 0N!offer];
	 offer }

query: { [x] .trdr.i.query[ x[0];x[1];x[2];x[3] ] }

archive: { `:trdr set value `.trdr }
restore: { dc:get `.trdr; `.trdr set dc }

\d .

servers:()
props:()
.trdr.updt: { props::select tname, tvalue by n:toffer from .trdr.tprops;
	     servers::select offer:n, server:s, ttype:ttype.k, pn:props[([]n);`tname], pv:props[([]n);`tvalue], offers:ttype.ni, service: { .sch.a2url[x;x] } each s from .trdr.offers }

.trdr.ttypes,:([k:enlist(`basic)]; v:enlist(`$"Basic service"); ni:0 )
.trdr.ttypes,:([k:enlist(`trdr)]; v:enlist(`$"Trader service"); ni:0 )

.trdr.def.host:.z.h
.trdr.def.port:15001

.trdr.def.s: raze (enlist(":"), ":" sv string each (.trdr.def.host;.trdr.def.port))

.trdr.s: $[ 0 < count getenv`QTRDR; getenv`QTRDR; .trdr.def.s ]

.trdr.t:(":" vs .trdr.s)

// @}

/ Check hosts match
if[ (.z.h <> `$.trdr.t[1]); 0N!("trdr: bad host"); .sys.exit 1];

/ Try the port
.trdr.tp1: @[value;("\\p ", .trdr.t[2]);`fail]

if[-11h = type .trdr.tp1; 0N!("trdr: bad port"; .trdr.t[2]; .trdr.tp1); .sys.exit 2];

// This is the server implementation's first export offer - itself.
// It uses a reserved port: usually 15001
// It is usually only used remotely
.trdr.ex1:.trdr.export (hsym `$.trdr.s;`trdr;`impl`qsys)

0N!("query: "; .trdr.query (`trdr;enlist(`impl); enlist(`qsys);1));

0N!("modify: "; .trdr.modify (.trdr.ex1;`trdr;(`impl`qsys)));

// Automatically deletes all offers from disconnected clients
.z.pc: { [x]
	while[ not null n:.trdr.cp ? x;
	      .trdr.withdraw[n];
	      .trdr.cp::.trdr.cp _ n]; }

.trdr.updt`

\l doth.k

status:.trdr.status
status`

\

.trdr.s: $[ 0 < count getenv`QTRDR; getenv`QTRDR; .trdr.def.s ]

any not null value .trdr.ttypes `basic

ex1:.trdr.export (hsym `$.trdr.s;`trdr;(`impl;`qsys))
0N!("export: "; ex1);
ex2:.trdr.export (hsym `$.trdr.s;`folio;(`name;`gro))
ex3:.trdr.export (hsym `$.trdr.s;`folio;(`name;`dry))

ex1

status`

0N!("query: "; .trdr.query (`trdr;enlist(`impl); enlist(`qsys);1));

status`

0N!("query2: "; qu1:.trdr.query (`folio;enlist(`name); `gro`dry`eaton;3));


0N!("modify: "; .trdr.modify (ex2;`folio;(`gro`gro)));

status`

\

0N!("withdraw: "; .trdr.withdraw[ex1]);



\

t:`trader
me:hsym `$.trdr.s
if[ null value .trdr.ttypes ttype; insert[`.trdr.ttypes;(t;me)] ];

/  Local Variables: 
/  mode:q 
/  q-prog-args: " -nodo -verbose -p 1444"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
