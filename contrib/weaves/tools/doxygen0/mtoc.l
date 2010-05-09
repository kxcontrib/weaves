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
 int ms0 = 0;

ID [a-zA-Z][0-9a-zA-Z_]*
WS [ \t]*

%s func funcDef paramList props methods
%s construct0
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
 BEGIN(INITIAL);
}

^{WS}properties {
 yy_push_state(props);
 yy_push_state(props0);
 ms0 = props;
}

^{WS}methods {
 yy_push_state(methods);
 yy_push_state(methods0);
 ms0 = methods;
}

<props0,methods0>\(.*\) {
 accessors.assign(yytext);
}

<props0,methods0>\n {
 (*yyout) << accessors0(accessors);
 accessors.assign("");
 ECHO;
 yy_pop_state();
 if (yy_flex_debug) (*yyout) << "sm: " << YYSTATE;
}

<props>^{WS}{ID}{WS}; {
  (*yyout) << "type ";
  ECHO;
  if (yy_flex_debug) (*yyout) << "sm: pr0: " << YYSTATE;
}

<props>^{WS}{ID}{WS}={WS}[^%\n]+{WS}; {
  (*yyout) << "type ";
  ECHO;
  if (yy_flex_debug) (*yyout) << "sm: pr1: " << YYSTATE;
}

 /* end last function */
<func>"%%" { 
 yy_push_state(doc);
 (*yyout) << "}\n/// ";
}

 /* close old comment, start new one */
<doc>"%%" {
 (*yyout) << "///";
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

<methods>^{WS}{ID}{WS}={WS}{ID}{WS} {
  yy_push_state(funcDef);
  tag1 = replace0(yytext, "=", "");
  (*yyout) << tag1;
}

<methods>^{WS}{ID}{WS}={WS}{ID}{WS} {
 if (ms0 == methods) {
  yy_push_state(funcDef);
  tag1 = replace0(yytext, "=", "");
  (*yyout) << tag1;
 } else {
  ECHO;
  yy_pop_state();
 }
}

<funcDef>\( {
 yy_pop_state();
 ECHO;
 yy_push_state(paramList);
}

<paramList>\){WS}; {
 if (yy_flex_debug) (*yyout) << "sm: p0: " << YYSTATE;
 yy_pop_state();
 ECHO;
}

<paramList>\){WS}[^;] {
 if (yy_flex_debug) (*yyout) << "sm: p1: " << YYSTATE;
 yy_pop_state();
 ECHO;
 (*yyout) << "{";
 yy_push_state(func);
}

<paramList>{ID} {
 (*yyout) << "type ";
 ECHO;
}

<doc>.* {
 ECHO;
}

<props,methods>^{WS}end{WS} {
 if (YYSTATE) BEGIN(INITIAL);
 if (yy_flex_debug) (*yyout) << "sm: pm0: " << YYSTATE;
}

<func,construct0>^{WS}(if|while|for|switch){WS} {
 ECHO;
 yy_push_state(construct0);
}

<construct0>^{WS}end{WS} {
 yy_pop_state();
}

<construct0>\;{WS}end{WS} {
 yy_pop_state();
}

<func>^{WS}end{WS} {
 (*yyout) << "}";
 yy_pop_state();
 if (yy_flex_debug) (*yyout) << "sm: end 0: " << YYSTATE;
 BEGIN(methods);
}

^{WS}end{WS} {
 (*yyout) << "}";
 if (yy_flex_debug) (*yyout) << "sm: end 1: " << YYSTATE;
}

<<EOF>> {
 return 0;
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
