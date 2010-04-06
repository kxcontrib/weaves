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
string accessors0(string fname);

%}

 int inCommentLine = 0; /* in comment line */
 int comment_caller;
 string tag1;
 string accessors;
 int linecount = 0;
 int flinecount = 0; // lineno() doesn't work

ID [a-zA-Z][0-9a-zA-Z_]*
WS [ \t]*

%s func funcDef paramList props methods
%x doc props0 methods0

%%

^{WS}classdef{WS} {
 (*yyout) << "class ";
}

^{WS}properties {
 yy_push_state(props0);
}

^{WS}methods {
 yy_push_state(methods0);
}

<props0,methods0>(.+) {
 accessors.assign(yytext);
}

<props0,methods0>\n {
 (*yyout) << accessors0(accessors);
 ECHO;
 yy_pop_state();
 if (YYSTATE == props0)
  yy_push_state(props);
 else
  yy_push_state(methods);
}

 /* end last function */
<func>"%%" { 
 comment_caller = YY_START;
 BEGIN(doc);
 (*yyout) << "}\n/// ";
 inCommentLine = 1; /* start of comment */
}

 /* close old comment, start new one */
<doc>"%%" {
 (*yyout) << "\n///";
 inCommentLine = 1; /* start of comment */
}

 /* first token */
"%%" { 
 comment_caller = YY_START;
 BEGIN(doc);
 (*yyout) << "/// ";
 inCommentLine = 1; /* start of comment */
}

<doc>"%" {
 /* just a symbol in a comment */
 if (inCommentLine) 
  ECHO;
 else {
  /* part of current comment block */
  (*yyout) << "*";
  inCommentLine = 1;
 }
}

<doc>.+$ {
  ECHO;
}

 /* start comment block */
"%" { 
 (*yyout) << "/// ";
 comment_caller = YY_START;
 BEGIN(doc);
 inCommentLine = 1; /* start of comment */
}

<doc>\n {
 ECHO; inCommentLine = 0;
 BEGIN(INITIAL);
}

^{WS}function {
 if (!inCommentLine) {
  (*yyout) << "\n";
  BEGIN(comment_caller);
 }

 (*yyout) << "void ";
 BEGIN(funcDef);
}

^{WS}function.*\[.*\].*= {
 if (!inCommentLine) {
  (*yyout) << "\n";
  BEGIN(comment_caller);
 }
 (*yyout) << "rets ";
 BEGIN(funcDef);
}

^{WS}function.*= {
 if (!inCommentLine) {
  (*yyout) << "\n";
  BEGIN(comment_caller);
 }
 (*yyout) << "ret ";
 BEGIN(funcDef);
}

<funcDef>\( {
 ECHO;
 BEGIN(paramList);
}

<paramList>\) {
 ECHO;
 (*yyout) << "{\n";
 BEGIN(func);
}

<paramList>{ID} {
 (*yyout) << "type ";
 ECHO;
}

<doc>[0-9a-zA-Z]+ {
 if (!inCommentLine) {
  (*yyout) << "\n";
  BEGIN(comment_caller);
 }
 ECHO;
}

[0-9a-zA-Z]+ {
 ECHO;
}

^{WS}end{WS}$ {
 if (YYSTATE == props || YYSTATE == methods)
  yy_pop_state();
 else (*yyout) << "}";
}

<<EOF>> {
 (*yyout) << "}\n";
 return 1;
}

<*>^.*$ {
 linecount++;
 if (yy_flex_debug) (*yyout) << "default: " << yytext << "sm: " << YY_START;
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
