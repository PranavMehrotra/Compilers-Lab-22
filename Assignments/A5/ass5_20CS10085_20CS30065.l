%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "ass5_20CS10085_20CS30065_translator.h"
    #include "y.tab.h"
    int lineno = 1;
%}

%option noyywrap

%x single_line 
%x multi_line

/* regular definations and their corresponding regex */
/*regex for keyword */
keyword                         "auto"|"enum"|"restrict"|"unsigned"|"break"|"extern"|"return"|"void"|"case"|"float"|"short"|"volatile"|"char"|"for"|"signed"|"while"|"const"|"goto"|"sizeof"|"_Bool"|"continue"|"if"|"static"|"_Complex"|"default"|"inline"|"struct"|"_Imaginary"|"do"|"int"|"switch"|"double"|"long"|"typedef"|"else"|"register"|"union"

id_non_digit                    [A-Za-z_]
id_digit                        [A-Za-z_0-9]
digit                           [0-9]
nonzero_digit                   [1-9]
digit_seq                       {digit}+

sign                            [+-]
escape                          "\\\'"|"\\\""|"\\\?"|"\\\\"|"\\a"|"\\b"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v"
ws                              [ \t\r]
newline                         [\n]
delim                           {ws}+

identifier                      {id_non_digit}{id_digit}*

integer_constant                {nonzero_digit}{digit}*|"0"

fractional_constant             {digit_seq}?\.{digit_seq}|{digit_seq}\.
exponent                        [eE]{sign}?{digit_seq}
floating_constant               {fractional_constant}{exponent}?|{digit_seq}{exponent} 

enum_constant                   {identifier}
c_char                          [^\'\n\\]|{escape}
c_seq                           {c_char}+
char_constant                   \'{c_seq}\'

constant                        {integer_constant}|{floating_constant}|{enum_constant}|{char_constant}
s_char                          [^\"\\\n]|{escape}
s_seq                           {s_char}+
string                          \"{s_seq}?\"

punctuators                     "["|"]"|"("|")"|"{"|"}"|"."|"-"|">"|"++"|"--"|"&"|"*"|"+"|"-"|"~"|"!"|"/"|"%"|"<<"|">>"|"<"|">"|"<="|">="|"=="|"!="|"^"|"|"|"&&"|"||"|"?"|":"|";"|"..."|"="|"*="|"/="|"%="|"+="|"-="|"<<="|">>="|"&="|"^="|"|="|","|"#"
%%

    /* transition rules corresponding to keywords */
"auto"                          { return AUTO; }
"break"                         { return BREAK; }
"case"                          { return CASE; }
"char"                          { return CHAR; }
"const"                         { return CONST; }
"continue"                      { return CONTINUE; }
"default"                       { return DEFAULT; }
"do"                            { return DO; }
"double"                        { return DOUBLE; }
"else"                          { return ELSE; }
"enum"                          { return ENUM; }
"extern"                        { return EXTERN; }
"float"                         { return FLOAT; }
"for"                           { return FBITWISE_OR; }
"goto"                          { return GOTO; }
"if"                            { return IF; }
"inline"                        { return INLINE; }
"int"                           { return INT; }
"long"                          { return LONG; }
"register"                      { return REGISTER; }
"restrict"                      { return RESTRICT; }
"return"                        { return RETURN; }
"short"                         { return SHBITWISE_ORT; }
"signed"                        { return SIGNED; }
"sizeof"                        { return SIZEOF; }
"static"                        { return STATIC; }
"switch"                        { return SWITCH; }
"unsigned"                      { return UNSIGNED; }
"void"                          { return VOID; }
"volatile"                      { return VOLATILE; }
"while"                         { return WHILE; }
"_Bool"                         { return _BOOL; }
"_Complex"                      { return _COMPLEX; }
"_Imaginary"                    { return _IMAGINARY; }

    /* for identifier, the synthesised attribute value will be the pointer to the symbol table entry.*/
{identifier}                    { yylval.idval = curr_symb_table->search_lexeme(yytext); return IDENTIFIER; }

    /* for terminals other than identifier, the terminals will have synthesised attribute value equal to yytext */
{integer_constant}              { yylval.intval = atoi(yytext); return INTEGER_CONSTANT; }
{floating_constant}             { yylval.floatval = yytext; return FLOATING_CONSTANT; }
{char_constant}                 { yylval.charval = yytext; return CHARACTER_CONSTANT; }
{string}                        { yylval.stringval = yytext; return STRING_LITERAL; }


    /* Regex for single line comments will be active only when // is read */
"//"                            { BEGIN(single_line); }
<single_line>.                  { }
<single_line>\n                 { BEGIN(INITIAL);}

    /* Regex for multi line comments will be active only when /* is read */
"/*"                            { BEGIN(multi_line); }
<multi_line>.                   { }
<multi_line>\n                  { }
<multi_line>"*/"                { BEGIN(INITIAL);}

"["                             { return LEFT_SQUARE; }
"++"                            { return SELF_INCREASE ; }
"/"                             { return F_SLASH; }
"?"                             { return QUESTION_MARK; }
"="                             { return ASSIGN ; }
","                             { return COMMA; }
"]"                             { return RIGHT_SQUARE; }
"("                             { return LEFT_PARENTHESES; }
"{"                             { return LEFT_CURLY; }
"}"                             { return RIGHT_CURLY; }
"."                             { return DOT; }
"->"                            { return ARROW; }
"*"                             { return MUL; }
"+"                             { return PLUS; }
"-"                             { return MINUS; }
"~"                             { return TILDE; }
"!"                             { return EXCLAMATION; }
"%"                             { return MODULO; }
"<<"                            { return LEFT_SHIFT; }
">>"                            { return RIGHT_SHIFT; }
"<"                             { return LESS_THAN; }
">"                             { return GREATER_THAN; }
"<="                            { return  LESS_THAN_EQUAL; }
">="                            { return GREATER_THAN_EQUAL; }
":"                             { return COLON; }
";"                             { return SEMI_COLON; }
"..."                           { return ELLIPSIS; }
"*="                            { return MUL_ASSIGN ; }
"/="                            { return DIV_ASSIGN ; }
"%="                            { return MODULO_ASSIGN ; }
"+="                            { return PLUS_ASSIGN ; }
"-="                            { return MINUS_ASSIGN ; }
"<<="                           { return LEFT_SHIFT_ASSIGN ; }
"--"                            { return SELF_DECREASE ; }
")"                             { return RIGHT_PARENTHESES; }
"&"                             { return BITWISE_AND; }
"=="                            { return EQUAL; }
"^"                             { return BITWISE_OR; }
"|"                             { return BITWISE_OR; }
"&&"                            { return LOGICAL_AND; }
"||"                            { return LOGICAL_BITWISE_OR; }
">>="                           { return RIGHT_SHIFT_ASSIGN ; }
"!="                            { return NOT_EQUAL; }
"&="                            { return BITWISE_AND_ASSIGN ; }
"|="                            { return BITWISE_OR_ASSIGN ; }
"^="                            { return BITWISE_XOR_ASSIGN ; }


{ws}                            { }
{newline}                       { lineno++;}
.                               { printf("Error in Line number: %d, Invalid token: %s read\n", lineno, yytext); return INVALID; }

%%
