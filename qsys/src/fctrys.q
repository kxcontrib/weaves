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

/// Production version of the creation function.
///
/// It passes two strings in the environment: the parent in Q_FCTRY and 
/// a nonce as a ticket: Q_NONCE.
i.cmd: { [x] es:"=" sv ("export Q_FCTRY";.Q.s1 string parent);
	es,:enlist ";";
	ms:"=" sv ("export Q_NONCE";.Q.s1 string m:.trdr.nonce`); ms,:enlist ";";
	c:" " sv (es;ms;"Qr -autoport";"-load";" " sv .sys.i.qloads;"> /dev/null 2>&1 &");
	(m;c) }

/// Debug version of the creation function
i.cmd: { [x] 
	es:"=" sv ("export Q_FCTRY";.Q.s1 string parent); es,:enlist ";";
	ms:"=" sv ("export Q_NONCE";.Q.s1 string m:.trdr.nonce`); ms,:enlist ";";
	c:" " sv (es;ms;"screen Qp -autoport";"-load";" " sv .sys.i.qloads);
	c }

i.clients: ("fctry.q";"fctryc.q";"fctryc0.q")

/// Debug version of the creation function
i.cmd0: { [x] 
	 es:"=" sv ("export Q_FCTRY";.Q.s1 string parent); es,:enlist ";";
	 ms:"=" sv ("export Q_NONCE";.Q.s1 string m:.trdr.nonce`); ms,:enlist ";";
	 c:" " sv (es;ms;"screen -dmS lxp1 Qp -autoport";"-qpath";.sys.i.cwd;"-load";" " sv i.clients);
	 (m;c) }

/// Method for clients to construct a child.
make: { [x] ms:i.cmd`; 0N!(" " vs ms[1]);
       system ms[1]; insert[`.fctry.i.children;(ms[0];`)] }

/// Method for a blank client
make0: { [x] ms:i.cmd0`;
	0N!(show " " vs ms[1]);
	system ms[1]; insert[`.fctry.i.children;(ms[0];`)] }

/// Call-back for the client.
updt: { [x;y] 0N!("updt";x);
       update n:`$y by i from `.fctry.i.children where m = `$x;
       select from .fctry.i.children where n = `$y }

\d .

schema[`.fctry.make]:"The instruction that will make another server."

/// Slightly different approach. If we are the factory, create a blank server
/// we load it by sending commands to it.

.fctry.splayname`;

.fctry.restate`;

// If we are not a child, then make a test one 
if[ .fctry.i.state = `parent; .t.a:.fctry.make0` ]

.fctry.retrade .fctry.i.state

\

/// Set the name of the table to load.
if[ 0 < count a:system"a"; schema[`splay]:string first a]

// Publish to the trader
.t.ttype: $[ 0 = count getenv`Q_FCTRY; `fctry; `splay]
.t.n: .trdr.modify0 (.t.ttype;(`name;`$schema`splay))
.t.n

// If we are a child callback
h:-1
if[ 0 < count s:getenv`Q_FCTRY;
   m:`$getenv`Q_NONCE;
   h: hopen hsym `$s;
   h (" . " sv (".fctry.updt"; .Q.s1 string (m;.t.n))) ]

// @}

/  Local Variables: 
/  mode:q 
/  q-prog-args: "-p 1444 -nodo -test -verbose -halt -load csvdb/lxp fctry.q fctrys.q"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
