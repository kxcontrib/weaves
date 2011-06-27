// weaves

/ Simple logging

\d .log

fileh:2
trace:0

tracer: { [m;l]
	 if[.log.trace <= 0; : ::];
	 .log.fileh ("trace: ", m, ": ");
	 { .log.fileh .Q.s1 x; .log.fileh " "; } each l;
	 .log.fileh "\n";
	 }

typed: { [m;l] .log.tracer[m;(type l; count l;
			      $[0 < count l; type first l; ::]; l)] }

toc2tic: { [m] .log.tracer[m; .sys.toc0` ]; .sys.tic0` ] }

\d .