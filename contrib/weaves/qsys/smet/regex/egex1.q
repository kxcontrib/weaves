// weaves

.egex.lib:`$".libs/libqregex"

0N!("Linkage: about to load"; .egex.lib);

0N!("Regular expression deletes: spaces ");

despace: .egex.lib 2:(`q_re_despace;2)

0N!("pass: "; 1.0);
b:"a b c"
d:()!()
a:despace[b;d]
(type a; a)

0N!("pass: "; 1.0);
b:"a  b  c "
d:()!()
a:despace[b;d]
(type a; a)

0N!("pass: "; 1.0);
b:""
d:()!()
a:despace[b;d]
(type a; a)

0N!("Regular expression deletes: puncts ");

depunct: .egex.lib 2:(`q_re_depunct;2)

0N!("pass: "; 1.0);
b:""
d:()!()
a:depunct[b;d]
(type a; a)

0N!("pass: "; 1.0);
b:"a b c"
d:()!()
a:depunct[b;d]
(type a; a)

0N!("pass: "; 1.0);
b:"a,  b,  c "
d:()!()
a:depunct[b;d]
(type a; a)

0N!("pass: "; 1.0);
b:"a,  b;  c: a/b \\or a's or d`s or - any! - (any) or [any] or {any}"
d:()!()
a:depunct[b;d]
(type a; a)

0N!("pass: "; 1.0);
b:"a,  b;  c: a/b \\or a's or d`s"
d:()!()
a:despace[depunct[b;d];d]
(type a; a)

0N!("pass: "; 1.0);
b:"a,  b;  c: a/b \\or a's or d`s or - any! - (any) or [any] or {any}"
d:()!()
a:despace[depunct[b;d];d]
(type a; a)

if[.sys.is_arg`exit; exit 0]