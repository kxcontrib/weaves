// weaves

/ Compares names against names from two tables.
/ t1 and t2.

/ Using my q script loader
.sys.qloader enlist("regex.q")

/ A dictionary of options. This is for Levenshtein
/ These settings give about 40 matches but biased toward "corp" "inc"
dctl:`icase`wreplace`least!1 1 0
.sim.d:0.7

.wt.r: { [x;y] .smet.lev.r[.regex.clean x; .regex.clean y;dctl] }
/ I don't use these, I prefer the Jaro-Winkler test

/ A dictionary of options. This is for Jaro-Winkler
/ These settings give about 40 matches
.sim.d:0.9
.sim.jrw:0.15
dctl1:`icase`least!1 0

.wt.r: { [x;y] .smet.jrw.r[.regex.clean x; .regex.clean y;dctl1;.sim.jrw] }

/ The tables can be shortened for testing
t1:0!(.sim.N#t1)
t2:0!(.sim.N#t2)

/ Clean the columns
t1:select n:first { .regex.clean x } each issuer by id from t1
t2:select n:first { .regex.clean x } each issuer by id from t2

/ A results table - foreign keys
res: ([] `t1$l:(); `t2$r:() )

/ Shorthand
fv: { first value x }

/ Check each record against every other using two layers of each processing
/ Outer: kx is the key, get the value and put in kv - the comparor
/ Inner: compare against every other. k1 is the key of the comparee. k1v is the value
/ Check they are not the same (the if[]), apply the .wt.r function
/ If it is greater than the .sim.d value (typically 0.9) push onto the results table.

{ kx: fv x; kv: fv t1 kx;
 { k1: fv x;
  if [k1 = first y; : ::];
  k1v: fv t2 k1; d:.wt.r[k1v;last y];
  if[d > .sim.d; insert[`res;(first y;k1)]]
  }[;(kx;kv)] each key t2
 } each key t1

/  Local Variables: 
/  mode:q 
/  q-prog-args: " -p 1444 -halt -debug -nodo -verbose -quiet -load ports.lst super0.q "
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:



