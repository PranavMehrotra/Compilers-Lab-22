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

%nonassoc RIGHT_PARENTHESES
%nonassoc ELSE
%start translation_unit

%%
primary_expression: IDENTIFIER
                  | INTEGER_CONSTANT
                  | FLOATING_CONSTANT
                  | CHARACTER_CONSTANT
                  | STRING_LITERAL
                  | LEFT_PARENTHESES expression RIGHT_PARENTHESES
                  ;

postfix_expression: primary_expression
                  | postfix_expression LEFT_SQUARE expression RIGHT_SQUARE
                  | postfix_expression LEFT_PARENTHESES argument_expression_listopt RIGHT_PARENTHESES
                  | postfix_expression DOT IDENTIFIER
                  | postfix_expression ARROW IDENTIFIER
                  | postfix_expression SELF_INCREMENT
                  | postfix_expression SELF_DECREMENT
                  | LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_CURLY initializer_list RIGHT_CURLY
                  | LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_CURLY initializer_list COMMA RIGHT_CURLY
                  ;

argument_expression_list: assignment_expression
                        | argument_expression_list COMMA assignment_expression
                        ;

unary_expression: postfix_expression
                | SELF_INCREMENT unary_expression
                | SELF_DECREMENT unary_expression
                | unary_operator cast_expression
                | sizeof unary_expression
                | sizeof LEFT_PARENTHESES type_name RIGHT_PARENTHESES
                ;

unary_operator: BITWISE_AND 
              | MUL 
              | PLUS 
              | MINUS 
              | TILDE 
              | EXCLAMATION
              ;
        
cast_expression: unary_expression
               | LEFT_PARENTHESES type_name RIGHT_PARENTHESES cast_expression
               ;

multiplicative_expression: cast_expression
                         | multiplicative_expression MUL cast_expression
                         | multiplicative_expression F_SLASH cast_expression
                         | multiplicative_expression MODULO cast_expression
                         ;

additive_expression: multiplicative_expression
                   | additive_expression PLUS multiplicative_expression
                   | additive_expression MINUS multiplicative_expression
                   ;

shift_expression: additive_expression
                | shift_expression LEFT_SHIFT additive_expression
                | shift_expression RIGHT_SHIFT additive_expression
                ;

relational_expression: shift_expression
                     | relational_expression LESS_THAN shift_expression
                     | relational_expression GREATER_THAN shift_expression
                     | relational_expression LESS_EQUAL_THAN shift_expression
                     | relational_expression GREATER_EQUAL_THAN shift_expression
                     ;

equality_expression: relational_expression
                   | equality_expression EQUAL relational_expression
                   | equality_expression NOT_EQUAL relational_expression
                   ;

AND_expression: equality_expression
              | AND_expression BITWISE_AND equality_expression
              ;

exclusive_OR_expression: AND_expression
                       | exclusive_OR_expression BITWISE_XOR AND_expression
                       ;

inclusive_OR_expression: exclusive_OR_expression
                       | inclusive_OR_expression BITWISE_OR exclusive_OR_expression
                       ;

logical_AND_expression: inclusive_OR_expression
                      | logical_AND_expression LOGICAL_AND inclusive_OR_expression

logical_OR_expression: logical_AND_expression
                     | logical_OR_expression LOGICAL_OR logical_AND_expression
                     ;

conditional_expression: logical_OR_expression
                      | logical_OR_expression QUESTION_MARK expression COLON conditional_expression
                      ;

assignment_expression: conditional_expression
                     | unary_expression assignment_operator assignment_expression
                     ;

assignment_operator: = 
                   | *= 
                   | /= 
                   | %= 
                   | += 
                   | -= 
                   | <<= 
                   | >>= 
                   | &= 
                   | ^= 
                   | |=
                   ;

expression: assignment_expression
          | expression , assignment_expression
          ;

constant_expression: conditional_expression
                   ;


declaration: declaration_specifiers init_declarator_listopt ;
           ;

declaration_specifiers: storage_class_specifier declaration_specifiersopt
                      | type_specifier declaration_specifiersopt
                      | type_qualifier declaration_specifiersopt
                      | function_specifier declaration_specifiersopt
                      ;

init_declarator_list: init_declarator
                    | init_declarator_list , init_declarator
                    ;

init_declarator: declarator
               | declarator = initializer
               ;


storage_class_specifier: extern
                       | static
                       | auto
                       | register
                       ;

type_specifier: void
              | char
              | short
              | int
              | long
              | float
              | double
              | signed
              | unsigned
              | _Bool
              | _Complex
              | _Imaginary
              | enum_specifier
              ;

specifier_qualifier_list: type_specifier specifier_qualifier_listopt
                        | type_qualifier specifier_qualifier_listopt
                        ;

enum_specifier: enum IDENTIFIERopt { enumerator_list }
              | enum IDENTIFIERopt { enumerator_list , }
              | enum IDENTIFIER
              ;

enumerator_list: enumerator
               | enumerator_list , enumerator
               ;

enumerator: enumeration_constant
          | enumeration_constant = constant_expression
          ;

type_qualifier: const
              | restrict
              | volatile
              ;

function_specifier: inline
                  ;

declarator: pointeropt direct_declarator
          ;

direct_declarator: IDENTIFIER
                 | ( declarator )
                 | direct_declarator [ type_qualifier_listopt assignment_expressionopt ]
                 | direct_declarator
                       [ static type_qualifier_listopt assignment_expression ]
                 | direct_declarator [ type_qualifier_list static assignment_expression ]
                 | direct_declarator [ type_qualifier_listopt * ]
                 | direct_declarator ( parameter_type_list )
                 | direct_declarator ( IDENTIFIER_listopt )
                 ;

pointer: * type_qualifier_listopt
       | * type_qualifier_listopt pointer
       | type_qualifier_list:
       | type_qualifier
       | type_qualifier_list type_qualifier
       ;

parameter_type_list: parameter_list
                   | parameter_list , ...
                   ;


parameter_list: parameter_declaration
              | parameter_list , parameter_declaration
              ;

parameter_declaration: declaration_specifiers declarator
                     | declaration_specifiers
                     ;

IDENTIFIER_list: IDENTIFIER
               | IDENTIFIER_list , IDENTIFIER
               ;

type_name: specifier_qualifier_list
         ;


initializer: assignment_expression
           | { initializer_list }
           | { initializer_list , }
           ;

initializer_list: designationopt initializer
                | initializer_list , designationopt initializer
                ;

designation: designator_list =
           ;

designator_list: designator
               | designator_list designator
               ;

designator: [ constant_expression ]
          | . IDENTIFIER
          ;

statement: labeled_statement
         | compound_statement
         | expression_statement
         | selection_statement
         | iteration_statement
         | jump_statement
         ;

labeled_statement: IDENTIFIER : statement
                 | case constant_expression : statement
                 ;

default : statement
        ;

compound_statement: { block_item_listopt }
                  | block_item_list:
                  | block_item
                  | block_item_list block_item
                  ;

block_item: declaration
          | statement
          ;

expression_statement: expressionopt ;
                    ;

selection_statement: if ( expression ) statement
                   | if ( expression ) statement else statement 
                   | switch ( expression ) statement
                   ;

iteration_statement: while ( expression ) statement
                   | do statement while ( expression ) ;
                   | for ( expressionopt ; expressionopt ; expressionopt ) statement
                   | for ( declaration expressionopt ; expressionopt ) statement
                   ;

jump_statement: goto IDENTIFIER ;
              | continue ;
              | break ;
              | return expressionopt ;
              ;

translation_unit: external_declaration
                | translation_unit external_declaration
                ;

external_declaration: function_definition
                    | declaration
                    ;

function_definition: declaration_specifiers declarator declaration_listopt compound_statement
                   ;

declaration_list: declaration
                | declaration_list declaration
                ;
                
%%