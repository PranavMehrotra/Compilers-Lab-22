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

assignment_operator: ASSIGNMENT 
                   | MUL_ASSIGNMENT 
                   | DIV_ASSIGNMENT 
                   | MODULO_ASSIGNMENT 
                   | PLUS_ASSIGNMENT 
                   | MINUS_ASSIGNMENT 
                   | LEFT_SHIFT_ASSIGNMENT 
                   | RIGHT_SHIFT_ASSIGNMENT 
                   | BITWISE_AND_ASSIGNMENT 
                   | BITWISE_XOR_ASSIGNMENT 
                   | BITWISE_OR_ASSIGNMENT
                   ;

expression: assignment_expression
          | expression COMMA assignment_expression
          ;

constant_expression: conditional_expression
                   ;


declaration: declaration_specifiers init_declarator_listopt SEMI_COLON
           ;

declaration_specifiers: storage_class_specifier declaration_specifiersopt
                      | type_specifier declaration_specifiersopt
                      | type_qualifier declaration_specifiersopt
                      | function_specifier declaration_specifiersopt
                      ;

init_declarator_list: init_declarator
                    | init_declarator_list COMMA init_declarator
                    ;

init_declarator: declarator
               | declarator ASSIGNMENT initializer
               ;


storage_class_specifier: EXTERN
                       | STATIC
                       | AUTO
                       | REGISTER
                       ;

type_specifier: VOID
              | CHAR
              | SHORT
              | INT
              | LONG
              | FLOAT
              | DOUBLE
              | SIGNED
              | UNSIGNED
              | _BOOL
              | _COMPLEX
              | _IMAGINARY
              | enum_specifier
              ;

specifier_qualifier_list: type_specifier specifier_qualifier_listopt
                        | type_qualifier specifier_qualifier_listopt
                        ;

enum_specifier: enum IDENTIFIERopt LEFT_CURLY enumerator_list RIGHT_CURLY
              | enum IDENTIFIERopt LEFT_CURLY enumerator_list COMMA RIGHT_CURLY
              | enum IDENTIFIER
              ;

enumerator_list: enumerator
               | enumerator_list COMMA enumerator
               ;

enumerator: enumeration_constant
          | enumeration_constant ASSIGNMENT constant_expression
          ;

type_qualifier: CONST
              | RESTRICT
              | VOLATILE
              ;

function_specifier: INLINE
                  ;

declarator: pointeropt direct_declarator
          ;

direct_declarator: IDENTIFIER
                 | LEFT_PARENTHESES declarator RIGHT_PARENTHESES
                 | direct_declarator LEFT_SQUARE type_qualifier_listopt assignment_expressionopt RIGHT_SQUARE
                 | direct_declarator
                       LEFT_SQUARE STATIC type_qualifier_listopt assignment_expression RIGHT_SQUARE
                 | direct_declarator LEFT_SQUARE type_qualifier_list STATIC assignment_expression RIGHT_SQUARE
                 | direct_declarator LEFT_SQUARE type_qualifier_listopt MUL RIGHT_SQUARE
                 | direct_declarator LEFT_PARENTHESES parameter_type_list RIGHT_PARENTHESES
                 | direct_declarator LEFT_PARENTHESES IDENTIFIER_listopt RIGHT_PARENTHESES
                 ;

pointer: MUL type_qualifier_listopt
       | MUL type_qualifier_listopt pointer
       ;

type_qualifier_list:
       | type_qualifier
       | type_qualifier_list type_qualifier
       ;

parameter_type_list: parameter_list
                   | parameter_list , ELLIPSIS
                   ;


parameter_list: parameter_declaration
              | parameter_list COMMA parameter_declaration
              ;

parameter_declaration: declaration_specifiers declarator
                     | declaration_specifiers
                     ;

IDENTIFIER_list: IDENTIFIER
               | IDENTIFIER_list COMMA IDENTIFIER
               ;

type_name: specifier_qualifier_list
         ;


initializer: assignment_expression
           | LEFT_CURLY initializer_list RIGHT_CURLY
           | LEFT_CURLY initializer_list COMMA RIGHT_CURLY
           ;

initializer_list: designationopt initializer
                | initializer_list COMMA designationopt initializer
                ;

designation: designator_list ASSIGNMENT
           ;

designator_list: designator
               | designator_list designator
               ;

designator: LEFT_SQUARE constant_expression RIGHT_SQUARE
          | DOT IDENTIFIER
          ;

statement: labeled_statement
         | compound_statement
         | expression_statement
         | selection_statement
         | iteration_statement
         | jump_statement
         ;

labeled_statement: IDENTIFIER COLON statement
                 | CASE constant_expression COLON statement
                 ;

default : statement
        ;

compound_statement: LEFT_CURLY block_item_listopt RIGHT_CURLY
                  ;

block_item_list:
                | block_item
                | block_item_list block_item
                ;

block_item: declaration
          | statement
          ;

expression_statement: expressionopt SEMI_COLON
                    ;

selection_statement: IF LEFT_PARENTHESES expression RIGHT_PARENTHESES statement
                   | IF LEFT_PARENTHESES expression RIGHT_PARENTHESES statement ELSE statement 
                   | SWITCH LEFT_PARENTHESES expression RIGHT_PARENTHESES statement
                   ;

iteration_statement: WHILE LEFT_PARENTHESES expression RIGHT_PARENTHESES statement
                   | DO statement WHILE LEFT_PARENTHESES expression RIGHT_PARENTHESES SEMI_COLON
                   | FOR LEFT_PARENTHESES expressionopt SEMI_COLON expressionopt SEMI_COLON expressionopt RIGHT_PARENTHESES statement
                   | FOR LEFT_PARENTHESES declaration expressionopt SEMI_COLON expressionopt RIGHT_PARENTHESES statement
                   ;

jump_statement: GOTO IDENTIFIER SEMI_COLON
              | CONTINUE SEMI_COLON
              | BREAK SEMI_COLON
              | RETURN expressionopt SEMI_COLON
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