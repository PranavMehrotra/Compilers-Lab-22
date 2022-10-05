%{
#include <string.h>
#include <iostream>
extern int yylex();
void yyerror(char *s);
%}

%union{
    int intval;
    float floatval;
    char *charval;
    char *stringval;
    char *idval;
}

%token _BOOL
%token _COMPLEX
%token _IMAGINARY
%token AUTO
%token BREAK
%token CASE 
%token CHAR
%token CONST
%token CONTINUE
%token DEFAULT
%token DO
%token DOUBLE
%token ENUM
%token EXTERN
%token FLOAT
%token FOR 
%token GOTO
%token IF
%token INLINE
%token INT
%token LONG
%token REGISTER
%token RESTRICT
%token RETURN
%token SHORT
%token SIGNED
%token SIZEOF
%token STATIC
%token SWITCH
%token UNION
%token UNSIGNED
%token VOID
%token VOLATILE
%token WHILE

%token<stringval> IDENTIFIER
%token<intval> INTEGER_CONSTANT
%token<floatval> FLOATING_CONSTANT
%token<charval> CHARACTER_CONSTANT
%token<idval> STRING_LITERAL



%token LEFT_SQUARE
%token SELF_INCREMENT
%token F_SLASH
%token QUESTION_MARK
%token ASSIGNMENT
%token COMMA
%token RIGHT_SQUARE
%token LEFT_PARENTHESES
%token LEFT_CURLY
%token RIGHT_CURLY
%token DOT
%token ARROW
%token MUL
%token PLUS
%token MINUS
%token TILDE
%token EXCLAMATION
%token MODULO
%token LEFT_SHIFT
%token RIGHT_SHIFT
%token LESS_THAN
%token GREATER_THAN
%token LESS_EQUAL_THAN
%token GREATER_EQUAL_THAN
%token COLON
%token SEMI_COLON
%token ELLIPSIS
%token MUL_ASSIGNMENT
%token DIV_ASSIGNMENT
%token MODULO_ASSIGNMENT
%token PLUS_ASSIGNMENT
%token MINUS_ASSIGNMENT
%token LEFT_SHIFT_ASSIGNMENT
%token HASH
%token SELF_DECREMENT
%token RIGHT_PARENTHESES
%token BITWISE_AND
%token EQUAL
%token BITWISE_XOR
%token BITWISE_OR
%token LOGICAL_AND
%token LOGICAL_OR
%token RIGHT_SHIFT_ASSIGNMENT
%token NOT_EQUAL
%token BITWISE_AND_ASSIGNMENT
%token BITWISE_OR_ASSIGNMENT
%token BITWISE_XOR_ASSIGNMENT

%token INVALID