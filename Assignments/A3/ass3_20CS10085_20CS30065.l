%{
#include<stdio.h>
#define KEYWORD                 1
#define IDENTIFIER              2
#define INTEGER_CONSTANT        3
#define FLOATING_CONSTANT       4
#define ENUMERATION_CONSTANT    5
#define CHARACTER_CONSTANT      6
#define STRING_LITERAL          7
#define PUNCTUATOR              8
#define MULTI_LINE_COMMENT      9
#define SINGLE_LINE_COMMENT     10
#define INVALID_TOKEN           11

%}


keyword                 "auto"|"enum"|"restrict"|"unsigned"|"break"|"extern"|"return"|"void"|"case"|"float"|"short"|"volatile"|"char"|"for"|"signed"|"while"|"const"|"goto"|"sizeof"|"_Bool"|"continue"|"if"|"static"|"_Complex"|"default"|"inline"|"struct"|"_Imaginary"|"do"|"int"|"switch"|"double"|"long"|"typedef"|"else"|"register"|"union"
id_non_digit            [A-Za-z_]
id_digit                [A-Za-z_0-9]

digit                   [0-9]
nonzero_digit           [1-9]
digit_seq               {digit}+

sign                    [+-]
escape                  "\\\'"|"\\\""|"\\\?"|"\\\\"|"\\\a"|"\\\b"|"\\\f"|"\\\n"|"\\\r"|"\\\t"|"\\\v"
ws                      [ \t\n\r]
delim                   {ws}+

identifier              {id_non_digit}{id_digit}*

integer_constant        {nonzero_digit}{digit}*

fractional_constant     {digit_seq}?\.{digit_seq}|{digit_seq}\.
exponent                [eE]{sign}?{digit_seq}
floating_constant       {fractional_constant}{exponent}?|{digit_seq}{exponent} 

enum_constant           {identifier}
c_char                  [^\'\n\\]|{escape}
c_seq                   {c_char}+
char_constant           \'{c_seq}\'

s_char                  [^\"\\\n]|{escape}
s_seq                   {s_char}+
string                  \"{s_seq}?\"

punctuators             "["|"]"|"("|")"|"{"|"}"|"."|"-"|">"|"++"|"--"|"&"|"*"|"+"|"-"|"~"|"!"|"/"|"%"|"<<"|">>"|"<"|">"|"<="|">="|"=="|"!="|"^"|"|"|"&&"|"||"|"?"|":"|";"|"..."|"="|"*="|"/="|"%="|"+="|"-="|"<<="|">>="|"&="|"^="|"|="|","|"#"
%%

{keyword}                       { return KEYWORD; }
{identifier}                    { return IDENTIFIER; }
{integer_constant}              { return INTEGER_CONSTANT; }
{floating_constant}             { return FLOATING_CONSTANT; }
{char_constant}                 { return CHARACTER_CONSTANT; }
{string}                        { return STRING_LITERAL; }
{punctuators}                   { return PUNCTUATOR; }
{delim}                         { ; }
.                               { return INVALID_TOKEN; }

%%

int yywrap(void)
{
    return 1;
}