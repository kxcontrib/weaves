// weaves

/ This demonstrates how to use the String metrics package.
/ To run this program you will need the utilities I've written in my sys directory.
/ The work is done by the script names0.q.

colnames: `id`issuer
t1: flip colnames!("SS";",")0:`:t1.csv
t2: flip colnames!("SS";",")0:`:t2.csv

t1: update issuer:{ string x } each issuer from t1
t2: update issuer:{ string x } each issuer from t2

.sim.N:20
.sim.N:max(count each (t2;t1))
0N!("Number of names: ";.sim.N);

/ Call the name testing system.

\t .sys.qloader enlist("names0.q")

/ 5 seconds for 650 names. 40 matches. 12 are usable.

/ Write the results to a CSV, review in an editor.
t1tot2:select l, l.n, r, r.n from res
.sch.t2csv[`t1tot2]

if[.sys.is_arg`exit; exit 0]

/  Local Variables: 
/  mode:q 
/  q-prog-args: " -p 1444 -halt -debug -nodo -verbose -quiet -load ports.lst super0.q "
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:



