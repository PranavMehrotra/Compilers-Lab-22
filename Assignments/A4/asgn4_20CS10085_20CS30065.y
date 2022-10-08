%{
#include <string.h>
#include <stdio.h>
extern int yylex();
extern int lineno;
void yyerror(char *s);
%}

%union{
    int intval;
    float floatval;
    char *charval;
    char *stringval;
    char *idval;
}

%token AUTO
%token BREAK
%token CASE 
%token CHAR
%token CONST
%token CONTINUE
%token DEFAULT
%token DO
%token DOUBLE
%token ELSE
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
%token UNSIGNED
%token VOID
%token VOLATILE
%token WHILE
%token _BOOL
%token _COMPLEX
%token _IMAGINARY

%token<stringval> IDENTIFIER
%token<intval> INTEGER_CONSTANT
%token<floatval> FLOATING_CONSTANT
%token<charval> CHARACTER_CONSTANT
%token<idval> STRING_LITERAL

%token LEFT_SQUARE
%token SELF_INCREASE 
%token F_SLASH
%token QUESTION_MARK
%token ASSIGN 
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
%token LESS_THAN_EQUAL
%token GREATER_THAN_EQUAL
%token COLON
%token SEMI_COLON
%token ELLIPSIS
%token MUL_ASSIGN 
%token DIV_ASSIGN 
%token MODULO_ASSIGN 
%token PLUS_ASSIGN 
%token MINUS_ASSIGN 
%token LEFT_SHIFT_ASSIGN 
%token SELF_DECREASE 
%token RIGHT_PARENTHESES
%token BITWISE_AND
%token EQUAL
%token BITWISE_XOR
%token BITWISE_OR
%token LOGICAL_AND
%token LOGICAL_OR
%token RIGHT_SHIFT_ASSIGN 
%token NOT_EQUAL
%token BITWISE_AND_ASSIGN 
%token BITWISE_OR_ASSIGN 
%token BITWISE_XOR_ASSIGN 

%token INVALID

%nonassoc RIGHT_PARENTHESES
%nonassoc ELSE


%start translation_unit

%%
primary_expression: IDENTIFIER
                  { printf("Line Number: %d  | Production: primary_expression ==> IDENTIFIER\n",lineno); printf("\tIDENTIFIER Value = %s\n", $1); }
                  | INTEGER_CONSTANT
                  { printf("Line Number: %d  | Production: primary_expression ==> INTEGER_CONSTANT\n",lineno); printf("\tINTEGER Value = %d\n", $1); }
                  | FLOATING_CONSTANT
                  { printf("Line Number: %d  | Production: primary_expression ==> FLOATING_CONSTANT\n",lineno); printf("\tFLOAT Value = %f\n", $1); }
                  | CHARACTER_CONSTANT
                  { printf("Line Number: %d  | Production: primary_expression ==> CHARACTER_CONSTANT\n",lineno); printf("\tCHAR Value = %s\n", $1); }
                  | STRING_LITERAL
                  { printf("Line Number: %d  | Production: primary_expression ==> STRING_LITERAL\n",lineno); printf("\tSTRING Value = %s\n", $1); }
                  | LEFT_PARENTHESES expression RIGHT_PARENTHESES
                  { printf("Line Number: %d  | Production: primary_expression ==> ( expression ) \n",lineno);}
                  ;

postfix_expression: primary_expression
                  { printf("Line Number: %d  | Production: postfix_expression ==> primary_expression \n",lineno); }
                  | postfix_expression LEFT_SQUARE expression RIGHT_SQUARE
                  { printf("Line Number: %d  | Production: postfix_expression ==> postfix_expression [ primary_expression ] \n",lineno); }
                  | postfix_expression LEFT_PARENTHESES argument_expression_listopt RIGHT_PARENTHESES
                  { printf("Line Number: %d  | Production: postfix_expression ==> postfix_expression ( primary_expression )\n",lineno); }
                  | postfix_expression DOT IDENTIFIER
                  { printf("Line Number: %d  | Production: postfix_expression ==> postfix_expression . IDENTIFIER \n",lineno);printf("\t IDENTIFIER Value = %s\n",$3); }
                  | postfix_expression ARROW IDENTIFIER
                  { printf("Line Number: %d  | Production: postfix_expression ==> postfix_expression => IDENTIFIER \n",lineno);printf("\t IDENTIFIER Value = %s\n",$3); }
                  | postfix_expression SELF_INCREASE
                  { printf("Line Number: %d  | Production: postfix_expression ==> postfix_expression ++ \n",lineno); }
                  | postfix_expression SELF_DECREASE 
                  { printf("Line Number: %d  | Production: postfix_expression ==> postfix_expression -- \n",lineno); }
                  | LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_CURLY initializer_list RIGHT_CURLY
                  { printf("Line Number: %d  | Production: postfix_expression =>( type_name ){ initialiser_list } \n",lineno); }
                  | LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_CURLY initializer_list COMMA RIGHT_CURLY
                  { printf("Line Number: %d  | Production: postfix_expression => ( type_name ){ initialiser_list , } \n",lineno);  }
                  ;

argument_expression_listopt: argument_expression_list
                            |
                            ;

argument_expression_list: assignment_expression
                        | argument_expression_list COMMA assignment_expression
                        ;

unary_expression: postfix_expression
                | SELF_INCREASE  unary_expression
                | SELF_DECREASE  unary_expression
                | unary_operator cast_expression
                | SIZEOF unary_expression
                | SIZEOF LEFT_PARENTHESES type_name RIGHT_PARENTHESES
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
                     | relational_expression LESS_THAN_EQUAL shift_expression
                     | relational_expression GREATER_THAN_EQUAL shift_expression
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

assignment_operator: ASSIGN  
                   | MUL_ASSIGN  
                   | DIV_ASSIGN  
                   | MODULO_ASSIGN  
                   | PLUS_ASSIGN  
                   | MINUS_ASSIGN  
                   | LEFT_SHIFT_ASSIGN  
                   | RIGHT_SHIFT_ASSIGN  
                   | BITWISE_AND_ASSIGN  
                   | BITWISE_XOR_ASSIGN  
                   | BITWISE_OR_ASSIGN 
                   ;

expression: assignment_expression
          | expression COMMA assignment_expression
          ;

constant_expression: conditional_expression
                   ;


declaration: declaration_specifiers init_declarator_listopt SEMI_COLON
           ;

init_declarator_listopt: init_declarator_list
                        |
                        ;

declaration_specifiers: storage_class_specifier declaration_specifiersopt
                      | type_specifier declaration_specifiersopt
                      | type_qualifier declaration_specifiersopt
                      | function_specifier declaration_specifiersopt
                      ;

declaration_specifiersopt: declaration_specifiers
                         |
                         ;

init_declarator_list: init_declarator
                    | init_declarator_list COMMA init_declarator
                    ;

init_declarator: declarator
               | declarator ASSIGN  initializer
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

specifier_qualifier_listopt: specifier_qualifier_list
                           |
                           ;

enum_specifier: ENUM identifieropt LEFT_CURLY enumerator_list RIGHT_CURLY
              | ENUM identifieropt LEFT_CURLY enumerator_list COMMA RIGHT_CURLY
              | ENUM IDENTIFIER
              ;

identifieropt: IDENTIFIER
              | 
              ;

enumerator_list: enumerator
               | enumerator_list COMMA enumerator
               ;

enumerator: IDENTIFIER
          | IDENTIFIER ASSIGN  constant_expression
          ;

type_qualifier: CONST
              | RESTRICT
              | VOLATILE
              ;

function_specifier: INLINE
                  ;

declarator: pointeropt direct_declarator
          ;

pointeropt: pointer
           |
           ;

direct_declarator: IDENTIFIER
                 | LEFT_PARENTHESES declarator RIGHT_PARENTHESES
                 | direct_declarator LEFT_SQUARE type_qualifier_listopt assignment_expressionopt RIGHT_SQUARE
                 | direct_declarator LEFT_SQUARE STATIC type_qualifier_listopt assignment_expression RIGHT_SQUARE
                 | direct_declarator LEFT_SQUARE type_qualifier_list STATIC assignment_expression RIGHT_SQUARE
                 | direct_declarator LEFT_SQUARE type_qualifier_listopt MUL RIGHT_SQUARE
                 | direct_declarator LEFT_PARENTHESES parameter_type_list RIGHT_PARENTHESES
                 | direct_declarator LEFT_PARENTHESES identifier_listopt RIGHT_PARENTHESES
                 ;

type_qualifier_listopt: type_qualifier_list
                      | 
                      ;

assignment_expressionopt: assignment_expression
                        |
                        ;


identifier_listopt: identifier_list
                  |
                  ;

pointer: MUL type_qualifier_listopt
       | MUL type_qualifier_listopt pointer
       ;


type_qualifier_list: type_qualifier
                    | type_qualifier_list type_qualifier
                    ;

parameter_type_list: parameter_list
                   | parameter_list COMMA ELLIPSIS
                   ;


parameter_list: parameter_declaration
              | parameter_list COMMA parameter_declaration
              ;

parameter_declaration: declaration_specifiers declarator
                     | declaration_specifiers
                     ;

identifier_list: IDENTIFIER
               | identifier_list COMMA IDENTIFIER
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

designationopt: designation
               |
               ;

designation: designator_list ASSIGN 
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
                 | DEFAULT COLON statement
                 ;

compound_statement: LEFT_CURLY block_item_listopt RIGHT_CURLY
                  ;

block_item_listopt: block_item_list
                  |
                  ;

block_item_list: block_item
                | block_item_list block_item
                ;

block_item: declaration
          | statement
          ;

expression_statement: expressionopt SEMI_COLON
                    ;

expressionopt: expression
              |
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

declaration_listopt: declaration_list
                     |
                     ;

declaration_list: declaration
                | declaration_list declaration
                ;
                
%%

void yyerror(char* s) {
    printf("ERROR [Line %d] : %s\n", lineno, s);
}