// weaves

/ Client side to the trader

\d .trdr

def.host:.z.h
def.port:15001

def.s: raze (enlist(":"), ":" sv string each (.trdr.def.host;.trdr.def.port))

s: hsym `$($[ 0 < count getenv`QTRDR; getenv`QTRDR; .trdr.def.s ])

hs: @[hopen; .trdr.s; `]

self: { port:value"\\p"; if[ 0 = port; : `];
       hsym `$(":", (string .z.h), ":", (string port)) }

impl: { `$(.os.filebase .z.f) }
prop: { (.trdr.impl`;.trdr.impl`) }

offers: ()

export: { [ttype;tprop]
	 if[ -11h = type .trdr.hs; : :: ];
	 me:.trdr.self`;
	 if[ null me; : :: ];
	 ttype: $[ not null ttype; ttype; .trdr.impl` ];
	 tprop: $[ (null tprop) or ((count tprop) < 2); .trdr.prop`; tprop ];
	 cmd: (" " sv (".trdr.export"; .Q.s1 (me;ttype;tprop)));
	 offer:.trdr.hs cmd;
	 offers,:offer; offer }

export0:{ .trdr.export[`;`] }

withdraw0: { [x]
	    cmd: (" " sv (".trdr.withdraw"; .Q.s1 x) );
	    .trdr.hs cmd }

withdraw: { [offer]
	   if[ -11h = type .trdr.hs; : :: ];
	   offer: $[ null offer; .trdr.offers; enlist offer];
	   withdraw0 each offer }

\d .

/ This doesn't work
.z.exit: { .trdr.withdraw`; exit x }

/ This does
.sys.exit: { $[.sys.is_arg`halt; 'halt; .z.exit[x]] }

\p 14001

.trdr.export0`

.sys.exit 0;

\

hclose .trdr.hs


withdraw: { [offer] :::}

modify: { [offer;dels;mods] ::: }

query: { [stype;constr;prefs;omax] ::: }

\d .

.trdr.s

\

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
