%{    /* lex2.l -- partial lex specification for Pascal    22 Jul 13 */

/* Copyright (c) 2013 Gordon S. Novak Jr. and The University of Texas at Austin
   */

/* This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see <http://www.gnu.org/licenses/>. */

/* To use:
        make lex2
        lex2
        x < 3.14            */

/* This file will work as given on a simple input such as:
   if i<j then x := 3.14

   Copy this file to lexan.l and expand it for your assignment.
   Use:
        make lexer
        lexer <graph1.pas
   */

#include <ctype.h>
#include "token.h"
#include "lexan.h"

int maketoken(int type, int which);
int install_id();
int install_fnum();

int install_num();
int install_str();
void install_coma();
void install_comb();

int yywrap();

/* If the lex yytext buffer turns out to be too small to hold comments,
   add the following lines:
 #undef YYLMAX
 #define YYLMAX 256
 */

TOKEN yylval;     /* This is the type of the lexical analyzer result */

%}

/* regular definitions */

delim    [ \t\n]
ws       {delim}+
letter   [A-Za-z]
digit    [0-9]
id       {letter}({letter}|{digit})*
number   {digit}+($|{ws}|;)
fnumber  {digit}+(\.{digit}+)?((E|e)[+\-]?{digit}+)?

string   ('([^']|(''))*')

commenta "{"
commentb "(*"

%%

{ws}      { /* no action and no return */ }
if        {return(maketoken(RESERVED, IF));}
then      {return(maketoken(RESERVED, THEN));}
else      {return(maketoken(RESERVED, ELSE));}
begin     {return(maketoken(RESERVED, BEGINBEGIN));}
end       {return(maketoken(RESERVED, END));}

"<"       {return(maketoken(OPERATOR, LT));}
"<="      {return(maketoken(OPERATOR, LE));}
"="       {return(maketoken(OPERATOR, EQ));}
"<>"      {return(maketoken(OPERATOR, NE));}
">"       {return(maketoken(OPERATOR, GT));}
">="      {return(maketoken(OPERATOR, GE));}
":="      {return(maketoken(OPERATOR, ASSIGN));}
"."       {return(maketoken(OPERATOR, DOT));}

"+"       {return(maketoken(OPERATOR, PLUS));}
"-"       {return(maketoken(OPERATOR, MINUS));}
"*"       {return(maketoken(OPERATOR, TIMES));}
"/"       {return(maketoken(OPERATOR, DIVIDE));}
"^"       {return(maketoken(OPERATOR, POINT));}

".."      {return(maketoken(DELIMITER, DOTDOT));}
";"       {return(maketoken(DELIMITER, SEMICOLON));}
","       {return(maketoken(DELIMITER, COMMA));}
":"       {return(maketoken(DELIMITER, COLON));}
"("       {return(maketoken(DELIMITER, LPAREN));}
")"       {return(maketoken(DELIMITER, RPAREN));}
"["       {return(maketoken(DELIMITER, LBRACKET));}
"]"       {return(maketoken(DELIMITER, RBRACKET));}

and       {return(maketoken(OPERATOR, AND));}
or        {return(maketoken(OPERATOR, OR));}
not       {return(maketoken(OPERATOR, NOT));}
div       {return(maketoken(OPERATOR, DIV));}
mod       {return(maketoken(OPERATOR, MOD));}
in        {return(maketoken(OPERATOR, IN));}

array       {return(maketoken(RESERVED, ARRAY));}
case        {return (maketoken(RESERVED, CASE));}
const       {return (maketoken(RESERVED, CONST));}
do          {return (maketoken(RESERVED, DO));}
downto      {return (maketoken(RESERVED, DOWNTO));}
file        {return (maketoken(RESERVED, FILEFILE));}
for         {return (maketoken(RESERVED, FOR));}
function    {return (maketoken(RESERVED, FUNCTION));} 
goto        {return (maketoken(RESERVED, GOTO));}
label       {return (maketoken(RESERVED, LABEL));}
nil         {return (maketoken(RESERVED, NIL));}
of          {return (maketoken(RESERVED, OF));}
packed      {return (maketoken(RESERVED, PACKED));} 
procedure   {return (maketoken(RESERVED, PROCEDURE));}  
program     {return (maketoken(RESERVED, PROGRAM));}
record      {return (maketoken(RESERVED, RECORD));} 
repeat      {return (maketoken(RESERVED, REPEAT));} 
set         {return (maketoken(RESERVED, SET));}
to          {return (maketoken(RESERVED, TO));}
type        {return (maketoken(RESERVED, TYPE));}
until       {return (maketoken(RESERVED, UNTIL));}
var         {return (maketoken(RESERVED, VAR));}
while       {return (maketoken(RESERVED, WHILE));}
with        {return (maketoken(RESERVED, WITH));}

{id}      {return(install_id());}
{number}  {return(install_num());}
{fnumber} {return(install_fnum());}

{string}  {return (install_str());}
{commenta}  {(install_coma());}
{commentb}  {(install_comb());}

%%

/* Note that lex always returns two values:
   1. "What is it?": a small integer such as NUMBER that indicates the
      kind of item that was found; this is the return() value.
   2. The value itself.  This is yylval, which points to a TOKEN.   */

/* Make simple tokens. */
int maketoken(int type, int which)
  {
  yylval = (TOKEN) talloc();  /* Make new token, set yylval to point to it */
  yylval->tokentype = type;
  if (type == RESERVED)
     yylval->whichval = which - RESERVED_BIAS;
     else if (type == OPERATOR)
             yylval->whichval = which - OPERATOR_BIAS;
             else if (type == DELIMITER)
                     yylval->whichval = which - DELIMITER_BIAS;
                     else yylval->whichval = which;
  return(which);
  }

int install_id()
 { int i, c, n;
  yylval = (TOKEN) talloc();  /* Make new token, set yylval to point to it */
  yylval->tokentype = IDENTIFIERTOK;
  n = yyleng;            /* number of characters */
  if ( n > 15 ) n = 15;
  for (i = 0; i < n ; i++)
   { c = yytext[i];
          /* if (islower(c)) c = toupper(c); */ /* to raise to upper case */
     yylval->stringval[i] = c;
    };
  yylval->stringval[n] = '\0';
          /* printf("id  %10s   n = %4d\n", yytext, n); */
  return(IDENTIFIER);
 }

int install_fnum() {  /* Note -- you may use sscanf for this assignment. */
  float fnum;
  yylval = (TOKEN) talloc();   /* Make new token, set yylval to point to it */
  yylval->tokentype = NUMBERTOK;
  yylval->datatype = REAL;
       /* printf("num %10s   n = %4d\n",yytext,yyleng); */
  sscanf(yytext, "%f", &fnum);
  yylval->realval = fnum;
  return(NUMBER);
 }

int install_num()
{ 
  int n;
  yylval = (TOKEN) talloc();
  yylval->tokentype = NUMBERTOK;
  yylval->datatype = INTEGER;

  sscanf(yytext, "%d", &n);
  yylval->intval = n;
  return(NUMBER);
}
int install_str()
{ 
  int len, n = 0;
  yylval = (TOKEN) talloc();
  yylval->tokentype = STRINGTOK;

  len = yyleng;
  if( len > 17)
    len = 17;

  for (int i = 0; i < len-1; i++)
  {
    if (yytext[i+1] == '\'' && (i+1) != 1)
    {
      n++;
      i++;
    }
    int x = yytext[i+1];
    yylval->stringval[i-n] = x;
  }
  yylval->stringval[len-1-n] = '\0';    //terminate
  return(STRING);
}
void install_coma()   
{
  int n = 0;
  while (n != '}')
    n = input();
}
void install_comb()   
{
  int a, b = 0;
  a = input();
  b = input();
  while( a != '*' || b != ')' )
  {
    a = b;
    b = input();
  }
}

int yywrap() {  return(1);  }       /* lex may need this. */
