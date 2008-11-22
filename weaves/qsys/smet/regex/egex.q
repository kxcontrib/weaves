// weaves

.egex.lib:`$".libs/libqregex"

0N!("Linkage: about to load"; .egex.lib);

/ Simplest interface, take one (null sym) argument
/ This returns 1j

read_cycles:.egex.lib 2:(`q_get_first_cpu_frequency;1)

/ in: two args; out: boolean
matchre: .egex.lib 2:(`q_match;2)
markre: .egex.lib 2:(`q_re_location;2)
markire: .egex.lib 2:(`q_re_location1;3)

0N!("read_cycles: "; 1);
read_cycles`

tstr:"abcdefghijkkl"
count tstr
0N!("test string: "; tstr);


0N!("match: ");

0N!("passes: "; 4);
matchre[enlist("l");tstr]
matchre["l$";tstr]
matchre[".+";tstr]
matchre["b.+";tstr]

0N!("fails: "; 1);
a:matchre["z.+";tstr]
(type a; a)

0N!("mark: ");

0N!("passes: "; 1);
a:markre["b.+";tstr]
(type a; a)

0N!("fails: "; 1);
a:markre["z.+";tstr]
(type a; a)

/ Case insensitive option
0N!("case insensitive:");

0N!("passes: "; 1);
a:markire["B.+";tstr;1]
(type a; a)

0N!("fail: "; 1);
a:markire["B.+";tstr;0]
(type a; a)

if[.sys.is_arg`exit; exit 0]