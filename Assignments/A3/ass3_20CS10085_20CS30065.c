#include<stdio.h>
#define KEYWORD                 1
#define IDENTIFIER              2
#define CONSTANT                3
#define STRING_LITERAL          4
#define PUNCTUATOR              5
#define INVALID_TOKEN           6

extern int yylex();
extern int yylineno;
extern char* yytext;

int main(void)
{
    int x = yylex();
    while(x)
    {
        if(x==KEYWORD)printf("<KEYWORD, %s>\n",yytext);
        else if(x==IDENTIFIER)printf("<ID, %s>\n",yytext);
        else if(x==CONSTANT)printf("<CONSTANT, %s>\n",yytext);
        else if(x==PUNCTUATOR)printf("<PUNCTUATOR, %s>\n",yytext);
        else if(x==STRING_LITERAL)printf("<STRING LITERAL, %s>\n",yytext);
        else printf("<INVALID TOKEN, %s>\n",yytext);
        x = yylex();
    }
}
