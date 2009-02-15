// weaves

/ A tradeable object

\p

.tr.i.counter:1;
.tr.nonce: { [x] 
	    .tr.i.counter+:1;
	    d1:.sys.primed`;
	    d2:.sys.primed`;
	    t1:`long$.z.z;
	    t2:.tr.i.counter + .z.i;
	    n1:(t1 * t2 * t1) div d1;
	    n2:(t2 * t1 * t2) div d2;
	    r0:(-2)#.Q.x12 `long$.tr.i.counter;
	    r1:(-3)#.Q.x12 `long$.z.i;
	    r2:(((-3)#.Q.x12 n1), (()#reverse .Q.x12 n2) );
	    (`$(r2,r1,r0)) }

.tr.nonce`

n:5
do[5;show .tr.nonce`]


\

 

x: $[ null x; .z.i + rand .z.i; x + .z.i];
m:`$(.Q.x12 (.z.i + n + (2 * rand n) * (3 * rand n) * (5 * rand n) * (7 * rand n) * x));
m

/ .sys.qloader enlist("trdrc.q")

\

/ Example of how to modify

.trdr.modify0[`folios;(`name;`gro)]


/ if[ not value "\\p"; .sys.autoport`]

/ .sys.autoport

/  q-prog-args: "-nodo -verbose -quiet -autoport"

/  Local Variables: 
/  mode:q 
/  q-prog-args: "-nodo -verbose -quiet -autoport 12901"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
