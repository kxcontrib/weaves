/*
 * Permission to use, copy, modify, and distribute this software and its
 * documentation under the terms of the GNU General Public License is hereby 
 * granted. No representations are made about the suitability of this software 
 * for any purpose. It is provided "as is" without express or implied warranty.
 * See the GNU General Public License for more details.
 *
 * Ian Martins (ianxm@jhu.edu)
 * Walter Eaves <walter.eaves@bigfoot.com>
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
string is_q(const char *s, const char *q0, const char *r0);
string accessors0(string fname);
string static0(string fname);
string replace0(const char *s, const char *q0, const char *r0);

%}

 string tag1;
 string accessors;
 int linecount = 0;

ID [a-zA-Z][0-9a-zA-Z_]*
WS [ \t]*

%s func funcDef paramList props methods
%s props0 methods0 class0 classes classes1
%x doc

%%

^{WS}classdef{WS}{ID} {
 tag1 = replace0(yytext, "classdef", "class");
 (*yyout) << tag1;
 yy_push_state(class0);
}

<class0>< {
 (*yyout) << ":";
 yy_push_state(classes);
}

<classes>{ID} {
 (*yyout) << "public " << replace0(yytext, ".", "_");
 yy_pop_state();
 yy_push_state(classes1);
}

<classes1>{ID} {
 (*yyout) << ", public " << replace0(yytext, ".", "_");
}

<classes,classes1,class0>\n {
 (*yyout) << " {";
 ECHO;
 yy_pop_state();
}

^{WS}properties {
 yy_push_state(props);
 yy_push_state(props0);
}

^{WS}methods {
 yy_push_state(methods);
 yy_push_state(methods0);
}

<props0,methods0>\(.*\) {
 if (yy_flex_debug) (*yyout) << "sm: " << YYSTATE;
 accessors.assign(yytext);
}

<props0,methods0>\n {
 (*yyout) << accessors0(accessors);
 accessors.assign("");
 ECHO;
 yy_pop_state();
}

 /* end last function */
<func>"%%" { 
 yy_push_state(doc);
 (*yyout) << "}\n/// ";
}

 /* close old comment, start new one */
<doc>"%%" {
 yy_pop_state();
 yy_push_state(doc);
 (*yyout) << "\n///";
}

 /* first token */
"%%" { 
 yy_push_state(doc);
 (*yyout) << "/// ";
}

<doc>"%" {
 ECHO;
}

<doc>.+$ {
  ECHO;
}

 /* start comment block */
"%" { 
 (*yyout) << "/// ";
 yy_push_state(doc);
}

<doc>\n {
 ECHO;
 yy_pop_state();
}

^{WS}function{WS}{ID}{WS} {
 (*yyout) << "void ";
 yy_push_state(funcDef);
 (*yyout) << replace0(yytext, "function", "");
}

^{WS}function{WS}{ID}{WS}={WS}{ID}{WS} {
 yy_push_state(funcDef);
 tag1 = replace0(yytext, "function", "");
 tag1 = replace0(tag1.c_str(), "=", "");
 (*yyout) << tag1;
}

<funcDef>\( {
 yy_pop_state();
 ECHO;
 yy_push_state(paramList);
}

<paramList>\){WS}; {
 yy_pop_state();
 ECHO;
}

<paramList>\) {
 yy_pop_state();
 ECHO;
 (*yyout) << "{\n";
 yy_push_state(func);
}

<paramList>{ID} {
 (*yyout) << "type ";
 ECHO;
}

<doc>.* {
 ECHO;
}

<props,methods>^{WS}end{WS}$ {
 yy_pop_state();
}

^{WS}end{WS}$ {
 (*yyout) << "}";
}

<<EOF>> {
 (*yyout) << "}\n";
 return 1;
}

<*>^.*$ {
 linecount++;
 if (yy_flex_debug) (*yyout) << "sm: " << YYSTATE;
 REJECT;
}

%%

#ifndef __GNUC__
int main(int argc, char **argv) {
 yyin = (argc>1) ? fopen(argv[1], "r") : stdin;
 yylex();
 return EXIT_SUCCESS;
}
#endif

/* Local Variables: */
/* mode: indented-text */
/* comment-column: 80 */
/* comment-start: "\/*" */
/* comment-end: "*\/" */
/* End: */
