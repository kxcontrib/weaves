// @file egex.q
// @brief Regular expressions demonstration - basic
// @author weaves
//
// I've chosen to use the POSIX regular expression library.
// GNU support it, but POSIX doesn't support GNU.
// @n
// The net effect is that to do sub-string matching you need to put 
// your regular expressions into a pair of brackets.

.egex.lib:`$".libs/libqregex"

0N!("Linkage: about to load"; .egex.lib);

/ Simplest interface, take one (null sym) argument
/ This returns 1j

read_cycles:.egex.lib 2:(`q_get_first_cpu_frequency;1)

/ Simple CRC-32

.crc32.str:.egex.lib 2:(`q_crc32;1)

0N!("crc32: ",string .crc32.str["abc"]);
0N!("crc32: ",string .crc32.str["abc1"]);


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

/ Expecting four passes, but one fails in script mode, but works on the command-line

/ Case insensitive option doesn't work either
0N!("case insensitive:");

0N!("fail: "; 1);
a:markire["B.+";tstr;0]
(type a; a)

0N!("passes: "; 1);
a:markire["B.+";tstr;1]
(type a; a)

0N!("passes: "; 4);
a:matchre[enlist "l";tstr]
a

if[not a; .sys.exit[1]]

matchre["l$";tstr]
matchre[".+";tstr]
matchre["b.+";tstr]

0N!("fails: "; 1);
a:matchre["z.+";tstr]
(type a; a)

0N!("mark: ");

0N!("fails: "; 1);
a:markre["z.+";tstr]
(type a; a)

0N!("passes: "; 1);
a:markre["b.+";tstr]
(type a; a)

if[.sys.is_arg`exit; exit 0]

/  Local Variables: 
/  mode:q 
/  q-prog-args: "-halt -load help.q -nodo -verbose -quiet"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
