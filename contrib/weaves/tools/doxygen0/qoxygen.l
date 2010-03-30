/** 
 * @file qoxygen.l
 *
 * Convert q/kdb+ code into a c like script that doxygen might understand.
 */

%option stack
%s def defbody fn args fnbody doc
%x end table string block coldata

%%

 /*****************************************
  * pass through doc comments
  */

^[ \t]*\/\/+[ \t]* {
	printf("/// ");
	yy_push_state(doc);
}

<doc>[\r\n]+ {
	printf("\n");
	yy_pop_state();
}

 /*****************************************
  * convert definitions to c style functions
  * and variables
  */

<INITIAL>^[ \t]*[[:alpha:]][[:alnum:]_]*[ \t]*/: {
	printf("%s", yytext);
	yy_push_state(def);
}

<def>:[ \t]* {
	printf("=");
	yy_pop_state();
	yy_push_state(defbody);
}

<defbody>[\r\n]+ {
	printf(";\n");
	yy_pop_state();
}

<defbody>[ \t]+\/[^:] {
	printf("; ");
	yy_pop_state();
}

<defbody>[,;] {
	printf(" ");
}

<def>:[ \t]*\{[ \t]* {
	printf("(");
	yy_pop_state();
	yy_push_state(fn);
}

<fn>\[ {
	yy_pop_state();
	yy_push_state(args);
}

<args>; {
	printf(",");
}

<fn>. |
<args>\] {
	printf(") {");
	yy_pop_state();
	yy_push_state(fnbody);
}

<fn,fnbody>\} {
	printf("};");
	yy_pop_state();
}

<defbody,fnbody>\" {
	printf("%s", yytext);
	yy_push_state(string);
}

<fnbody>\{ {
	yy_push_state(block);
}

<fnbody>(.|[\r\n]+) {
	//printf(".");
}

<string>(\\\"|\\\\) {
	printf("%s", yytext);
}
<string>\" {
	printf("%s", yytext);
	yy_pop_state();
}

<block>\} {
	yy_pop_state();
}
<block>. {
}

 /*****************************************
  * tables
  */

<def>:[ \t]*\([ \t]*/\[  {
	printf("=(");
	yy_pop_state();
	yy_push_state(table);
}

<table>[\];]+ {
	printf("%s\n   ", yytext);
}

<table>: {
	printf(" :\t", yytext);
}

<table>\( {
	printf("%s", yytext);
	yy_push_state(coldata);
}

<table>\) {
	printf("\n);\n");
	yy_pop_state();
}

<coldata>\) {
	printf("%s", yytext);
	yy_pop_state();
}

 /*****************************************
  * remove anything left over
  */

^\\[\r\n]+ {
	yy_push_state(end);
}

<INITIAL,end>(.|\r) {
	//printf("%d",YYSTATE);
}

%%

int main(int argc, char **argv) {
	yyin = (argc>1) ? fopen(argv[1], "r") : stdin;
	yylex();
	return EXIT_SUCCESS;
}
