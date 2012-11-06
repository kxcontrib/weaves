// @file time01t.q
// @brief UTC time functions demonstration - basic
// @author weaves
//
// @note

.time01t.lib:`$".libs/libqtime"

0N!("Linkage: about to load"; .time01t.lib);

/ Simplest interface, take one (null sym) argument
/ This returns 1j

utime0:.time01t.lib 2:(`q_utime0;1)

0N!(type utime0[]; utime0[]);

utime1:.time01t.lib 2:(`q_utime1;1)

x0:utime1[]
0N!(type x0; ; `int$floor x0; .Q.f[8;] x0 - floor x0 );

utime2:.time01t.lib 2:(`q_utime2;2)
utime3:.time01t.lib 2:(`q_utime3;1)

parts: { [dt] dt0:`date$dt; tm0:`time$dt;
	x0: (dt0.year;dt0.mm;dt0.dd; `hh$tm0; `mm$tm0; `ss$tm0; `int$tm0 mod 1000);
	x0: { `int$x } each x0;
	0N!(x0);
	utime2[ x0; 0 ] }

dt0: 2000.01.01T00:00:00.000
dt0
x0: parts @ dt0
x1: utime3 @ `real$x0

dt0: .z.z
dt0
x0: parts @ dt0
" " sv string each (type x0; floor x0; x0 - floor x0)
x1: utime3 @ x0

if[.sys.is_arg`exit; exit 0]

/  Local Variables: 
/  mode:q 
/  q-prog-args: "-halt -load help.q -nodo -verbose -quiet"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
