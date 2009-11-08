// @file fctry.q
// @author weaves
// @brief A factory service for splayed tables.

// @addtogroup factories Factory service
//
// Provides a means of creating another server for a splay.
// With it, you can then set the .Q.view as needed.
//
// @note
//
// This is very Unix. It would be good if I could block the make call until
// I know the child has been built. This would need a pipe.
// 
// @{

schema: $[.sys.undef[`.;`schema]; ()!(); schema ]

.fctry.schema::schema

\d .fctry

/// Record children in this table
i.children: ([] m:`symbol$(); n:`symbol$());

/// Identity of the factory.
i.parent: { [] .sch.a2hsym . (.z.h;system"p") }

parent: $[0 < count s:getenv`Q_FCTRY; hsym `$s; .fctry.i.parent` ]

// Scripts the client should load: fctry0.q does the callback
i.clients: ("fctry.q";"fctryc.q";"fctryc0.q")

/// Debug version of the creation function
i.cmd0: { [x] 
	 es:"=" sv ("export Q_FCTRY";.Q.s1 string parent); es,:enlist ";";
	 ms:"=" sv ("export Q_NONCE";.Q.s1 string m:.trdr.nonce`); ms,:enlist ";";
	 c:" " sv (es;ms;"screen -dmS lxp1 Qp -autoport";"-qpath";.sys.i.cwd;"-load";" " sv i.clients);
	 (m;c) }

/// Method to construct an empty child
make0: { [x] ms:i.cmd0`;
	0N!(show " " vs ms[1]);
	system ms[1]; insert[`.fctry.i.children;(ms[0];`)] }

/// Call-back for the empty child
updt: { [x;y] 0N!("updt";x);
       update n:`$y by i from `.fctry.i.children where m = `$x;
       select from .fctry.i.children where n = `$y }

/// Find the full path of the loaded splay
splaypath: { a:(`$.fctry.schema`splay) = { `$.os.basename x } each .sys.i.qloads; first .sys.i.qloads where a }

i.fetch: { [x] exec first n from .fctry.i.children where not null n }

i.release: { [x] delete from `.fctry.i.children where n = x }

/// Load function
i.cmd: { [x] 
	c:" " sv (".sys.qloader enlist"; .Q.s1 x);
	c1:"; " sv (c;".fctry.mature`");
	c1 }

.fctry.hopen: { [x] 
	       if[ null a:.fctry.i.fetch`; : ()];
	       a1:.trdr.query1 a;
	       if[ null a2:(a1 @ `s); : ()];
	       (a; hopen hsym a2) }

/// Method for parent to load the child.
///
/// Blocked call to load. Release and make a new child.
make: { [x1]
       x: $[ null x1; .fctry.schema`splaypath; x1 ];
       h1:.fctry.hopen`;
       if[ 0 = count h1; : ::];
       ms:i.cmd x;
       h1[1](ms);
       i.release h1[0];
       make0`;
       h1[0] }

\d .

schema[`.fctry.make]:"The instruction that will make another server."

/// Slightly different approach. If we are the factory, create a blank server
/// we load it by sending commands to it.

.fctry.splayname`;

.fctry.restate`;

// If we are not a child, then make a test one 
if[ .fctry.i.state = `parent; .t.a:.fctry.make0` ]

.fctry.retrade .fctry.i.state

.fctry.schema[`splaypath]:.fctry.splaypath`;

\

// Later a client calls us and tells us to load

.fctry.ch1: .fctry.hopen`

.fctry.make`

// @}

/  Local Variables: 
/  mode:q 
/  q-prog-args: "-p 1444 -nodo -test -verbose -halt -load csvdb/lxp fctry.q fctrys.q"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
