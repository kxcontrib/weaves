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

using namespace std;

int yyFlexLexer::yywrap() {
    return ::yywrap();
}

/// variety of cleanups.
string deQ(string fname);

/// variety of cleanups.
string asclassQ(string fname);
string namespace0(string fname);
string namespace1(string fname);
string namespacen();

%}

	int comment_caller;
	string fname;
	string ns0;
	string ns1;
	int linecount = 0;
	int flinecount = 0; // lineno() doesn't work

ID	[.a-zA-Z][0-9a-zA-Z_.]*
QID	\"[.a-zA-Z][0-9a-zA-Z_. ]*\"
WS	[ \t]*
DEF     (<-)|(=)

%s def defbody fn args fnbody doc nsdef
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

<INITIAL>^[ \t]*[.]*[[:alpha:]][[:alnum:]_.]*[ \t]*/: {
	fname = fname.assign(yytext);
	bool classed = fname.find_first_of(".") != -1;

	if (classed) {
	  ns1 = namespace1(fname);
	  fname = namespacen();
	  if (yy_flex_debug) (*yyout) << "sm: id: class !impl: "
	     << YYSTATE << fname << std::endl;

	  (*yyout) << "namespace " << ns1.c_str() << " { " << fname;
	  yy_push_state(nsdef);
         } else {
	  fname = deQ(fname);
	  if (yy_flex_debug) (*yyout) << "sm: id: !impl: "
	     << YYSTATE << fname << std::endl;
	  (*yyout) << fname;
	  yy_push_state(def);
	 }
}

<nsdef,def>:[ \t]* {
	printf("=");
	yy_push_state(defbody);
}

<defbody>[\r\n] {
	printf(";\n");
	yy_pop_state();
	if (YYSTATE == nsdef) printf(" }");
        yy_pop_state();
}

<defbody>[ \t]+\/[^:] {
	printf("; ");
	yy_pop_state();
	if (YYSTATE == nsdef) printf(" }");
        yy_pop_state();
}

<defbody>[,;] {
	printf(" ");
}

<nsdef,def>:[ \t]*\{[ \t]* {
	printf("(");
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
	if (YYSTATE == nsdef) printf(" }");
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
  * \d .tmp or \d tmp starts a namespace until eof or another \d
  */

^\\d[ \t].+$ {
   if (ns0.length() > 0) printf("}");

   fname = fname.assign(yytext);
   ns0 = namespace0(fname);
   printf("/* %s */ ", yytext);
   if (ns0.length() > 0) 
      printf("namespace %s { ", ns0.c_str());
}

 /*****************************************
  * remove anything left over
  */

^\n { /* blank lines */
   printf("\n");
}

^\\[a-ce-zA-Z].*$ { /* commands other than \d */
   printf("/* %s */", yytext);
}

^\\\n { /* Terminal comment */
   if (ns0.length() > 0) printf("}");
   
   ns0.assign("");
   yy_push_state(end);
}

<INITIAL,end>(.|\r) {
	//printf("%d",YYSTATE);
}

<*><<EOF>>	{
   if (ns0.length() > 0) printf("}");
   
   ns0.assign("");
   yy_push_state(end);
   return(0);
}

%%

/* Local Variables: */
/* mode: indented-text */
/* comment-column: 80 */
/* comment-start: "\/*" */
/* comment-end: "*\/" */
/* End: */
