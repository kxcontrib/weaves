/**
 * @file rtocc.l
 * @brief Scanner for R files to Doxygen.
 *
 * The commment character token to indicate a Doxygen comment is ##'
 * @n
 * There's a fair bit of skipping of input. The most common mistake is to put a 
 * comment on a line that doesn't define anything.
<code>
##' A message
plot(x)

##' A function
plotter <- function(x) {}
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

%}

	int comment_caller;
	string fname;
	int linecount = 0;
	int flinecount = 0; // lineno() doesn't work

ID	[.a-zA-Z][0-9a-zA-Z_.]*
QID	\"[.a-zA-Z][0-9a-zA-Z_. ]*\"
WS	[ \t]*
DEF     (<-)|(=)

%x funcDef varDef  def1 fcall
%x ignore commentLine commentLine1 code commented defining paramList ignoring

%%

<*>^.*$	{
	linecount++;
	if (yy_flex_debug) (*yyout) << "sm: " << YY_START;
	REJECT;
	}

<defining>{DEF}{WS}function {
	BEGIN(funcDef);
	if (yy_flex_debug) (*yyout) << "func: " << fname;
}

<defining>{DEF}{WS} {
	BEGIN(varDef);
	if (yy_flex_debug) (*yyout) << "var: " << fname;
}

<funcDef>\(	{
		  (*yyout) << fname;
		  ECHO;
		  BEGIN(paramList);
		}

<varDef>\(	{
		  BEGIN(fcall);
		}

<varDef>.+$	{
		  (*yyout) << "type " << fname << " = ";
		  ECHO;
		  (*yyout) << ";";
		  BEGIN(ignore);
		}

<paramList>\)	{
		  ECHO;
		  (*yyout) << "{}" << "\t// " << flinecount << " \"" << tfilename << '"';
		  BEGIN(ignore);
		}

<paramList>{ID}	{
		  (*yyout) <<"type "; 
		  ECHO;
		}

<commented>^({ID}|{QID}) {
	fname = fname.assign(yytext);
        fname = replace_all_copy( fname, "\"", "" );
        fname = replace_all_copy( fname, ".", "_" );
	flinecount = linecount;

	if (yy_flex_debug) (*yyout) << "id: " << fname;
	BEGIN(defining);
}

<commented>. BEGIN(INITIAL); REJECT;

<*>^{WS}##'	{
		/* Doxygen comments */
		/* first token */
		  comment_caller = YY_START;
		  BEGIN(commentLine);
		  (*yyout) <<"///";
		}

<*>^{WS}[#]+[^'] {
		 /* Other comments */
		 /* first token */
		  comment_caller = YY_START;
		  BEGIN(ignore);
		}

<ignore>\n	(*yyout) << " " << endl;
<ignore>.	;

<commentLine>.*$ ECHO; BEGIN(commented);

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