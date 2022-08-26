#include<stdio.h>

extern int yylex();
extern int yylineno;
extern char* yytext;
int main(void)
{
    int x = yylex();
    while(x)

    {
        printf("%d\n",x);
        x = yylex();
    }
}
