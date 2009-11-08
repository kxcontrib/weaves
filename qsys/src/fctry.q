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

\d .fctry

i.states: `parent`child`adult`
i.state: `

splayname: { [x]
	    nm: $[ 0 = count s:system"a"; ""; string first s ];
	    schema[`splay]:nm }

/// Production version of the creation function.
///
/// It passes two strings in the environment: the parent in Q_FCTRY and 
/// a nonce as a ticket: Q_NONCE.
i.cmd: { [x] es:"=" sv ("export Q_FCTRY";.Q.s1 string parent); es,:enlist ";";
	ms:"=" sv ("export Q_NONCE";.Q.s1 string m:.trdr.nonce`); ms,:enlist ";";
	c:" " sv (es;ms;"Qr -autoport";"-load";" " sv .sys.i.qloads;"> /dev/null 2>&1 &");
	(m;c) }

/// Debug version of the creation function
i.cmd: { [x] 
	es:"=" sv ("export Q_FCTRY";.Q.s1 string parent); es,:enlist ";";
	ms:"=" sv ("export Q_NONCE";.Q.s1 string m:.trdr.nonce`); ms,:enlist ";";
	c:" " sv (es;ms;"screen Qp -autoport";"-load";" " sv .sys.i.qloads);
	c }

/// Method for clients to construct a child.
make: { [x] ms:i.cmd`; system ms[1]; insert[`.fctry.i.children;(ms[0];`)] }

/// Call-back for the client.
updt: { [x;y] 0N!("updt";x);
       update n:`$y from `.fctry.i.children where m = `$x }

// Publish to the trader
retrade: { [x] 
	  .trdr.modify0 (x;(`name;`$schema`splay)) }

restate: { [x]
	  // parents never change
	  s1: $[`fctrys.q in .sys.i.qloaded; `parent; .fctry.i.state ];
	  if[ s1 = `parent; : .fctry.i.state:s1];

	  // a child matures
	  s1: $[`fctryc.q in .sys.i.qloaded; `child; s1 ];
	  s1: $[(s1 = `child) and (0 < count .fctry.schema`splay); `adult; s1 ];
	  .fctry.i.state: s1;
	  s1 }

\d .

// @}

/  Local Variables: 
/  mode:q 
/  q-prog-args: "-p 1444 -nodo -test -verbose -halt -load csvdb/lxp fctry.q"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
