%{
//Auxiliary declarations 
#include<stdio.h>
#define KEYWORD                 1
#define IDENTIFIER              2
#define CONSTANT                3
#define STRING_LITERAL          4
#define PUNCTUATOR              5
#define INVALID_TOKEN           6
%}

/* Exclusive start state specified */
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
ws                              [ \t\n\r]
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

    /* transition rules*/
{keyword}                       { return KEYWORD; }
{identifier}                    { return IDENTIFIER; }
{constant}                      { return CONSTANT; }
{string}                        { return STRING_LITERAL; }
{punctuators}                   { return PUNCTUATOR; }
{delim}                         { ; }

    /* Regex for single line comments will be active only when // is read */
"//"                            { BEGIN(single_line); }
<single_line>.                  { }
<single_line>\n                 { BEGIN(INITIAL);}

    /* Regex for multi line comments will be active only when /* is read */
"/*"                            { BEGIN(multi_line); }
<multi_line>.                   { }
<multi_line>\n                  { }
<multi_line>"*/"                { BEGIN(INITIAL);}
.                               { return INVALID_TOKEN; }
%%
/* Auxiliary function yywrap declared */ 
int yywrap(void)
{
    return 1;
}