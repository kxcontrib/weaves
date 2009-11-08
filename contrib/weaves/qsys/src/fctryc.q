// @file fctryc.q
// @author weaves
// @brief A factory created server for splayed tables.

// @addtogroup factories Factory created server
//
// Provides a means of creating another server for a splay. This server is
// created as a blank, then initialized.
//
// @note
//
// This is very Unix. It would be good if I could block the make call until
// I know the child has been built. This would need a pipe.
// 
// @{

schema: $[.sys.undef[`.;`schema]; ()!(); schema ]
schema[`.fctry.announce]:"How we communicate we have loaded."
.fctry.schema::schema

// Receive an array of things to load.
.fctry.loader: { [x]
		r1:@[.sys.qloader;x;`qload];
		r1 } 

h:-1
// On construction we call back.
.fctry.announce: { [x] h::-1;
		  m: .fctry.schema`nonce;
		  h:: hopen hsym .fctry.schema`parent;
		  h (" . " sv (".fctry.updt"; .Q.s1 string (m; x))) }

.fctry.mature: { [x]
		.fctry.splayname`;
		.fctry.restate`;
		.fctry.retrade .fctry.i.state }

.fctry.i.m: all(0 < count getenv`Q_FCTRY;0 < count getenv`Q_NONCE)
if[ not .fctry.i.m; .sys.exit -1]

.fctry.schema[`parent]: `$getenv`Q_FCTRY
.fctry.schema[`nonce]: `$getenv`Q_NONCE

// @}

/  Local Variables: 
/  mode:q 
/  q-prog-args: "-p 1444 -nodo -test -verbose -load fctry.q fctryc.q"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
