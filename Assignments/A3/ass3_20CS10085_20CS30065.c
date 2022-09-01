#include<stdio.h>
#define KEYWORD                 1                       //define all the macros used in the lex file 
#define IDENTIFIER              2
#define CONSTANT                3
#define STRING_LITERAL          4
#define PUNCTUATOR              5
#define INVALID_TOKEN           6

extern int yylex();                                     //include yylex(), yytext using extern
extern char* yytext;

int main(void)
{
    int x = yylex();                                    //read a lexeme
    while(x)                                            //check the type of lexeme and print an appropriate token
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
