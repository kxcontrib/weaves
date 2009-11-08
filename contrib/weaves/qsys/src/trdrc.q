// @file trdrc.q
// @author weaves
// @brief Implementation of the client side of the trader.


// @brief Client side to the trader.

// @addtogroup trclient Trader Client
// The implementation of the interface to make a call on the trader.
// @{

// When loaded basic offers are posted into this dictionary.

.trdr.i.offers: ()!()


\d .trdr

// Defaults for finding a trader - host.
def.host:.z.h

// Defaults for finding a trader - port.
def.port:15001

// Defaults for finding a trader.
def.s: raze (enlist(":"), ":" sv string each (.trdr.def.host;.trdr.def.port))

// Defaults for finding a trader accesing QTRDR
s: hsym `$($[ 0 < count getenv`QTRDR; getenv`QTRDR; .trdr.def.s ])

// A specification for ourselves. host and port.
self: { port:value"\\p"; if[ 0 = port; : `];
       hsym `$(":", (string .z.h), ":", (string port)) }

// @brief The nonce counter.
.i.counter:1;

// @brief A relatively unique identifier for each offer.
// Although defined in the client part, this is mostly used by the 
// server when it receives a request to export.
// @note
// A nonce function uses a counter, in base 12
// [4 rand][4 rand][3 pid][1 counter]
nonce: { [x] 
	    .trdr.i.counter+:1;
	    d1:.sys.primed`;
	    d2:.sys.primed`;
	    t1:`long$.z.z;
	    t2:.trdr.i.counter + .z.i;
	    n1:((t1 + rand t2) + (t1 * t2 * t1)) div d1;
	    n2:((t2 + rand t1) + (t2 * t1 * t2)) div d2;
	    r0:(-1)#.Q.x12 `long$(.trdr.i.counter mod 12);
	    r1:(-3)#.Q.x12 `long$.z.i;
	    r2:(((-4)#.Q.x12 n1),(reverse (-4)#.Q.x12 n2));
	    (`$(r2,r1,r0)) }

// @brief a default type for the implementation.
// Usually the type of an export is the script file.
// It can use the last loaded file sys_i_qloaded.
// It can also use a nonce.
impl: { [x] if[null .z.f;
	       $[any not null .sys.i.qloaded;
		 : `$.os.filebase string last .sys.i.qloaded;
		 : .trdr.nonce` ] ];
       `$(.os.filebase .z.f) }

// @brief Default properties for an export offer.
// Implementations are usually a name and a value.
// So a list of at least two elements is needed.
// A default is returned of two calls to imp().
prop: { [x] if[(not null x) and (2 <= count x); : x]; 
       (.trdr.impl`;.trdr.impl`) }

// @brief The export function. Post an offer to the trader.
export: { [ttype;tprop]
	 if[ -11h = type .trdr.hs; : :: ];
	 me:.trdr.self`;
	 if[ null me; : :: ];
	 ttype: $[ not null ttype; ttype; .trdr.impl` ];
	 tprop: $[ (all null tprop) or ((count tprop) < 2); .trdr.prop`; tprop ];
	 cmd: (" " sv (".trdr.export"; .Q.s1 (me;ttype;tprop)));
	 offer:.trdr.hs cmd;
	 .trdr.i.offers[offer]::(me;ttype;tprop); offer }

// @brief A simple call to export(), it assumes defaults.
export0:{ .trdr.export[`;`] }

// @brief Implementation for withdraw().
// This will withdraw from trdr_i_offers before issuing the
// withdraw at the server.
withdraw0: { [x]
	    cmd: (" " sv (".trdr.withdraw"; .Q.s1 x) );
	    .trdr.i.offers::.trdr.i.offers _ x;
	    .trdr.hs cmd }

// @brief Withdraw an offer at the trader server.
withdraw: { [offer]
	   if[ -11h = type .trdr.hs; : :: ];
	   offer: $[ null offer; key .trdr.i.offers; enlist offer];
	   withdraw0 each offer }

// @brief Query the trader for a type, and a list of of properties.
// If the properties or the preferences are null, it will send the
// trdr_prop().
query: { [ttype;tprop;tpref;omax]
	if[ -11h = type .trdr.hs; : :: ];
	ttype: $[ not null ttype; ttype; .trdr.impl` ];
	tprop: $[ (all null tprop) or ((count tprop) < 2); .trdr.prop`; tprop ];
	tpref: $[ (all null tpref) or ((count tpref) < 2); .trdr.prop`; tpref ];
	0N!(ttype;tprop;tpref;omax);
	cmd: (" " sv (".trdr.query"; .Q.s1 (ttype;tprop;tpref;omax) ) );
	.trdr.hs cmd }

// @brief Query the server using the defaults.
query0: { [x]
	if[ -11h = type .trdr.hs; : :: ];
	 hsym first .trdr.query[`;`;`;1] }

// @brief The offers made by this exporter.
offers: { [x] .trdr.i.offers }

// @brief Modify the offer at the server.
// This is the low-level remote call on the server.
modify: { [x] .trdr.hs(".trdr.modify ", .Q.s1 x) }

// Makes a modify call on the server - takes a list
// It takes (`ttype;(`name;`value))
i.modify0: { [x] if[ -11h = type .trdr.hs; : :: ];
	    ttype: $[0 <> type x; `; $[ 1 <= count x; x[0]; `] ];
	    tprops: $[0 <> type x; `; $[ 2 <= count x; x[1]; `] ];
	    ttype: $[null ttype; .trdr.impl`; ttype];
	    tprops: $[11h <> type tprops; .trdr.prop`; tprops];
	    offer:.trdr.modify (first key .trdr.offers`; ttype; tprops);
	    .trdr.i.offers[offer]::(first first value .trdr.offers`;ttype;tprops);
	    offer }

// @brief Abbreviated local version of modify.
modify0: { [x] if[ -11h = type .trdr.hs; : :: ];
	  if[.sys.undef[`.trdr;`offered];
	     n:.trdr.i.modify0 x; 
	     .trdr.offered:x; : n];
	  if[ not (.trdr.offered ~ x);
	     n:.trdr.i.modify0 x; 
	     .trdr.offered:x; : n];
	  first key .trdr.i.offers }

\d .

// @}

/ If running on a port, check we are not the trader.
/ If we are not, export
/ If we are, then run the trader.

if[ (value "\\p");
   $[ .trdr.s <> .trdr.self`;
     [ .trdr.hs:: @[hopen; .trdr.s; `];
      / This doesn't work
      .z.exit:: { .trdr.withdraw`; exit x };
      / This does
      .sys.exit:: { $[.sys.is_arg`halt; 'halt; .z.exit[x]] };
      .trdr.export0`; ::
      ];
     .sys.qloader enlist("trdr.q") ]
   ]

/ Run this and you get a double entry. Use tester.q

/  Local Variables: 
/  mode:q 
/  q-prog-args: "-p 1444 -nodo -verbose -halt"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
