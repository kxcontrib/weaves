/**
 * @file qoxygen2.l
 * @brief Scanner for Q files to Doxygen.
 *
 * The commment character token to indicate a Doxygen comment is //
 * @n
 * There's a fair bit of skipping of input. The most common mistake is to put a 
 * comment on a line that doesn't define anything.
<code>
// A function message
plot: { [x] x }

// Another function in a non-present class 
.t.plot: { [x] x }

// A class
\d .t
// A function in a class
plot: { [x] x }
\d .

</code>
 
 */

/*
 * Permission to use, copy, modify, and distribute this software and its
 * documentation under the terms of the GNU General Public License is hereby 
 * granted. No representations are made about the suitability of this software 
 * for any purpose. It is provided "as is" without express or implied warranty.
 * See the GNU General Public License for more details.
 *
 * Walter Eaves <walter.eaves@bigfoot>
 */

%option debug
%option c++
%option yylineno

%option stack


%{
#include <string>
#include <iostream>
#include "lex.hh"

#include <iterator>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace boost;

int yyFlexLexer::yywrap() {
    return ::yywrap();
}

/// variety of cleanups.
string deR(string fname);

/// variety of cleanups.
string asclass(string fname);

%}

	int comment_caller;
	string fname;
	int linecount = 0;
	int flinecount = 0; // lineno() doesn't work

ID	[.a-zA-Z][0-9a-zA-Z_.]*
QID	\"[.a-zA-Z][0-9a-zA-Z_. ]*\"
WS	[ \t]*
DEF     (<-)|(=)

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

<doc>[\r\n] {
	printf("\n");
	yy_pop_state();
}

 /*****************************************
  * convert definitions to c style functions
  * and variables
  */

<*>^.*$	{
	linecount++;
	if (yy_flex_debug) (*yyout) << "sm: " << YY_START;
	REJECT;
	}

<INITIAL>^[ \t]*.[[:alpha:]][[:alnum:].]*[ \t]*/: {
	    fname = fname.assign(yytext);
	    fname = asclass(fname);
	    if (yy_flex_debug) (*yyout) << "sm: id: class !impl: "
	       << YYSTATE << fname << std::endl;

	(*yyout) << fname;

	yy_push_state(def);
}

<INITIAL>^[ \t]*[[:alpha:]][[:alnum:]_.]*[ \t]*/: {
	    fname = fname.assign(yytext);
	    fname = deR(fname);
	    if (yy_flex_debug) (*yyout) << "sm: id: !impl: " << YYSTATE << fname << std::endl;

	(*yyout) << fname;

	yy_push_state(def);
}

<def>:[ \t]* {
	printf("=");
	yy_pop_state();
	yy_push_state(defbody);
}

<defbody>[\r\n] {
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

<fnbody>. {
	// printf(".");
}

<fnbody>\n {
	printf("\n");
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

^\n {
   printf("\n");
}

^\\[a-zA-Z].*$ {
   printf("/* %s */", yytext);
}

^\\\n {
	yy_push_state(end);
}

<INITIAL,end>(.|\r) {
	//printf("%d",YYSTATE);
}

<*><<EOF>>	{
		  return(0);
		}


%%

/* Local Variables: */
/* mode: indented-text */
/* comment-column: 80 */
/* comment-start: "\/*" */
/* comment-end: "*\/" */
/* End: */