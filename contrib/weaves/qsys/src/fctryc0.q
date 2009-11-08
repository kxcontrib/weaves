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

.fctry.splayname`

.fctry.restate`

0N!("client";.fctry.i.state);

.t.n: .fctry.retrade .fctry.i.state

.fctry.announce .t.n


// @}

/  Local Variables: 
/  mode:q 
/  q-prog-args: "-p 1444 -nodo -test -verbose -load fctry.q fctryc.q"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
