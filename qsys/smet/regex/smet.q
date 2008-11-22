// weaves

.egex.lib:`$".libs/libqregex"

0N!("Linkage: about to load"; .egex.lib);

/ Case insensitive option
0N!("String metrics:");

0N!("Levenshtein distance:");

.lev.d: .egex.lib 2:(`q_lev_dist;3)

0N!("pass: "; 0);
a:.lev.d["abc";"abc";0]
(type a; a)

0N!("pass: "; 1);
a:.lev.d["abc";"abd";0]
(type a; a)

0N!("pass: case-sensitive "; 1);
a:.lev.d["abc";"abC";0]
(type a; a)

0N!("pass: "; 2);
a:.lev.d["abc";"abd";1]
(type a; a)

0N!("Levenshtein distance ratio:");

.lev.r: .egex.lib 2:(`q_lev_ratio;3)

0N!("pass: "; 1.0);
a:.lev.r["abc";"abc";0]
(type a; a)

0N!("pass: "; 1.0);
a:.lev.r["abc";"abd";0]
(type a; a)

0N!("pass: "; 1.0);
a:.lev.r["abc";"abd";1]
(type a; a)

0N!("Levenshtein distance ratio: control");

0N!("Levenshtein distance ratio: null dict");
ctl:()!()
ctl[`icase]:1

0N!("pass: "; 1.0);
a:.lev.r["abc";"abd";ctl]
(type a; a)

0N!("Levenshtein distance ratio: un-null dict 1");
dtl: (enlist `icase)!enlist 1
type dtl

0N!("pass: "; 1.0);
a:.lev.r["abc";"abd";dtl]
(type a; a)

0N!("Levenshtein distance ratio: un-null dict 2");
dtl: `icase`least`wreplace`merrily! 1 1 1 2
( type dtl; count key dtl)

0N!("pass: "; 1.0);
a:.lev.r["abc";"abd";dtl]
(type a; a)

0N!("Levenshtein distance ratio: un-null dict 2: lower-case ");
dtl: `icase`least`wreplace`merrily! 1 1 1 2
( type dtl; count key dtl)

0N!("pass: "; 1.0);
b:"abc"
d:"ABD"
a:.lev.r[b;d;dtl]
(type a; a)
(type b; b)
(type d; d)

0N!("Levenshtein distance ratio: un-null dict 2: unleast ");
dtl: `icase`least`wreplace`merrily! 1 0 1 2
( type dtl; count key dtl)

0N!("pass: "; 1.0);
b:"abc"
d:"abdd"
a:.lev.r[b;d;dtl]
(type a; a)
(type b; b)
(type d; d)

0N!("Jaro-Winkler distance ratio: un-null dict 2: least ");

.lev.jw.r: .egex.lib 2:(`q_lev_jaro_winkler_ratio;4)

dtl: `icase`least!1 0
( type dtl; count key dtl)

0N!("pass: "; 1.0);
b:"Dinsdale"
d:enlist "D"
a:.lev.jw.r[b;d;dtl;`float$0N ]
(type a; a)
(type b; b)
(type d; d)

.lev.r["";"";dtl]

if[.sys.is_arg`exit; exit 0]