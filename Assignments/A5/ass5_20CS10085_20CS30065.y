%{
#include "ass5_20CS10085_20CS30065_translator.h"
#include <string.h>
#include <stdio.h>

extern int yylex();
extern int lineno;
void yyerror(char *s);

%}

%union{
    int intval;
    char *floatval;
    char *charval;
    char *stringval;
    int inst_num;
    char unary_op;
    int num_param;
    expression* expr;
    statement* stm;
    ST_entry* idval;
    ST_entry_type* symbol_type;
    array_data_type* arr;
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

%token<symbol_type> IDENTIFIER
%token<intval> INTEGER_CONSTANT
%token<floatval> FLOATING_CONSTANT
%token<charval> CHARACTER_CONSTANT
%token<stringval> STRING_LITERAL

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

// Non-terminals of type unaryOp (unary operator)

%%
primary_expression: IDENTIFIER
                  { 
                    
                  }
                  
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
                  { printf("Line Number: %d  | Production: postfix_expression ==>( type_name ){ initialiser_list } \n",lineno); }
                  
                  | LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_CURLY initializer_list COMMA RIGHT_CURLY
                  { printf("Line Number: %d  | Production: postfix_expression ==> ( type_name ){ initialiser_list , } \n",lineno);  }
                  ;

argument_expression_listopt: argument_expression_list
                            { printf("Line Number: %d  | Production: argument_expression_list_opt ==> argument_expression_list \n",lineno); }
                            
                            |
                            { printf("Line Number: %d  | Production: argument_expression_list_opt ==> Epsilon \n",lineno); }
                            ;

argument_expression_list: assignment_expression
                        { printf("Line Number: %d  | Production: argument_expression_list ==> assignment_expression \n",lineno); }
                        
                        | argument_expression_list COMMA assignment_expression
                        { printf("Line Number: %d  | Production: argument_expression_list ==> argument_expression_list , assignment_expression \n",lineno); }
                        ;

unary_expression: postfix_expression
                { printf("Line Number: %d  | Production: unary_expression ==> postfix_expression\n",lineno); }
                
                | SELF_INCREASE  unary_expression
                { printf("Line Number: %d  | Production: unary_expression ==> ++unary_expression \n",lineno); }
                
                | SELF_DECREASE  unary_expression
                { printf("Line Number: %d  | Production: unary_expression ==> --unary_expression \n",lineno); }
                            
                | unary_operator cast_expression
                { printf("Line Number: %d  | Production: unary_expression ==> unary_expression cast_expression \n",lineno); }
                            
                | SIZEOF unary_expression
                { printf("Line Number: %d  | Production: unary_expression ==> sizeof unary_expression \n",lineno); }
                            
                | SIZEOF LEFT_PARENTHESES type_name RIGHT_PARENTHESES
                { printf("Line Number: %d  | Production: unary_expression ==> sizeof ( type_name )\n",lineno); }
                ;

unary_operator: BITWISE_AND 
              { printf("Line Number: %d  | Production: unary_operator ==> &\n",lineno); }
              
              | MUL 
              { printf("Line Number: %d  | Production: unary_operator ==> *\n",lineno); }
              
              | PLUS 
              { printf("Line Number: %d  | Production: unary_operator ==> +\n",lineno); }
              
              | MINUS 
              { printf("Line Number: %d  | Production: unary_operator ==> -\n",lineno); }
              
              | TILDE 
              { printf("Line Number: %d  | Production: unary_operator ==> ~\n",lineno); }
              
              | EXCLAMATION
              { printf("Line Number: %d  | Production: unary_operator ==> !\n",lineno); }
              ;
        
cast_expression: unary_expression
               { printf("Line Number: %d  | Production: cast_expression ==> unary_expression\n",lineno); }
               
               | LEFT_PARENTHESES type_name RIGHT_PARENTHESES cast_expression
               { printf("Line Number: %d  | Production: cast_expression ==> ( type_name ) cast_expression\n",lineno); }
               ;

multiplicative_expression: cast_expression
                         { printf("Line Number: %d  | Production: multiplicative_expression ==> cast_expression\n",lineno); }
                         
                         | multiplicative_expression MUL cast_expression
                         { printf("Line Number: %d  | Production: multiplicative_expression ==> multiplicative_expression * cast_expression\n",lineno); }
                         
                         | multiplicative_expression F_SLASH cast_expression
                         { printf("Line Number: %d  | Production: multiplicative_expression ==> multiplicative_expression / cast_expression\n",lineno); }
                         
                         | multiplicative_expression MODULO cast_expression
                         { printf("Line Number: %d  | Production: multiplicative_expression ==> multiplicative_expression %% cast_expression\n",lineno); }
                         ;

additive_expression: multiplicative_expression
                   { printf("Line Number: %d  | Production: additive_expression ==> multiplicative_expression\n",lineno); }
                   
                   | additive_expression PLUS multiplicative_expression
                   { printf("Line Number: %d  | Production: additive_expression ==> additive_expression + multiplicative_expression\n",lineno); }
                   
                   | additive_expression MINUS multiplicative_expression
                   { printf("Line Number: %d  | Production: additive_expression ==> additive_expression - multiplicative_expression\n",lineno); }
                   ;

shift_expression: additive_expression
                { printf("Line Number: %d  | Production: shift_expression ==> assignment_expression\n",lineno); }
                
                | shift_expression LEFT_SHIFT additive_expression
                { printf("Line Number: %d  | Production: shift_expression ==> shift_expression << assignment_expression\n",lineno); }
                
                | shift_expression RIGHT_SHIFT additive_expression
                { printf("Line Number: %d  | Production: shift_expression ==> shift_expression >> assignment_expression\n",lineno); }
                ;

relational_expression: shift_expression
                     { printf("Line Number: %d  | Production: relational_expression ==> shift_expression\n",lineno); }
                     
                     | relational_expression LESS_THAN shift_expression
                     { printf("Line Number: %d  | Production: relational_expression ==> relational_expression < shift_expression\n",lineno); }
                     
                     | relational_expression GREATER_THAN shift_expression
                     { printf("Line Number: %d  | Production: relational_expression ==> relational_expression > shift_expression\n",lineno); }
                     
                     | relational_expression LESS_THAN_EQUAL shift_expression
                     { printf("Line Number: %d  | Production: relational_expression ==> relational_expression <= shift_expression\n",lineno); }
                     
                     | relational_expression GREATER_THAN_EQUAL shift_expression
                     { printf("Line Number: %d  | Production: relational_expression ==> relational_expression >= shift_expression\n",lineno); }
                     ;

equality_expression: relational_expression
                   { printf("Line Number: %d  | Production: equality_expression ==> relational_expression\n",lineno); }
                   
                   | equality_expression EQUAL relational_expression
                   { printf("Line Number: %d  | Production: equality_expression ==> equality_expression == relational_expression\n",lineno); }
                   
                   | equality_expression NOT_EQUAL relational_expression
                   { printf("Line Number: %d  | Production: equality_expression ==> equality_expression != relational_expression\n",lineno); }
                   ;

AND_expression: equality_expression
              { printf("Line Number: %d  | Production: AND_expression ==> equality_expression\n",lineno); }
              
              | AND_expression BITWISE_AND equality_expression
              { printf("Line Number: %d  | Production: AND_expression ==> AND_expression & equality_expression\n",lineno); }
              ;

exclusive_OR_expression: AND_expression
                       { printf("Line Number: %d  | Production: exclusive_OR_expression ==> AND_expression\n",lineno); }
                       
                       | exclusive_OR_expression BITWISE_XOR AND_expression
                       { printf("Line Number: %d  | Production: exclusive_OR_expression ==> exclusive_OR_expression ^ AND_expression\n",lineno); }
                       ;

inclusive_OR_expression: exclusive_OR_expression
                       { printf("Line Number: %d  | Production: inclusive_OR_expression ==> exclusive_OR_expression\n",lineno); }
                       
                       | inclusive_OR_expression BITWISE_OR exclusive_OR_expression
                       { printf("Line Number: %d  | Production: inclusive_OR_expression ==> inclusive_OR_expression | exclusive_OR_expression\n",lineno); }
                       ;

logical_AND_expression: inclusive_OR_expression
                      { printf("Line Number: %d  | Production: logical_AND_expression ==> inclusive_OR_expression\n",lineno); }
                      
                      | logical_AND_expression LOGICAL_AND inclusive_OR_expression
                      { printf("Line Number: %d  | Production: logical_AND_expression ==> logical_AND_expression && inclusive_OR_expression\n",lineno); }

logical_OR_expression: logical_AND_expression
                     { printf("Line Number: %d  | Production: logical_OR_expression ==> logical_AND_expression\n",lineno); }
                     
                     | logical_OR_expression LOGICAL_OR logical_AND_expression
                     { printf("Line Number: %d  | Production: logical_OR_expression ==> logical_OR_expression || logical_AND_expression\n",lineno); }
                     ;

conditional_expression: logical_OR_expression
                      { printf("Line Number: %d  | Production: conditional_expression ==> logical_OR_expression\n",lineno); }
                      
                      | logical_OR_expression QUESTION_MARK expression COLON conditional_expression
                      { printf("Line Number: %d  | Production: conditional_expression ==> logical_OR_expression ? expression ; conditional_expression\n",lineno); }
                      ;

assignment_expression: conditional_expression
                     { printf("Line Number: %d  | Production: assignment_expression ==> conditional_expression\n",lineno); }
                     
                     | unary_expression assignment_operator assignment_expression
                     { printf("Line Number: %d  | Production: assignment_expression ==> unary_expression assignment_operator assignment_expression\n",lineno); } 
                     ;

assignment_operator: ASSIGN
                   { printf("Line Number: %d  | Production: assignment_operator ==> =\n",lineno); }
                   
                   | MUL_ASSIGN  
                   { printf("Line Number: %d  | Production: assignment_operator ==> *=\n",lineno); }
                   
                   | DIV_ASSIGN
                   { printf("Line Number: %d  | Production: assignment_operator ==> /=\n",lineno); }  
                   
                   | MODULO_ASSIGN  
                   { printf("Line Number: %d  | Production: assignment_operator ==> %%=\n",lineno); }
                   
                   | PLUS_ASSIGN  
                   { printf("Line Number: %d  | Production: assignment_operator ==> +=\n",lineno); }
                   
                   | MINUS_ASSIGN  
                   { printf("Line Number: %d  | Production: assignment_operator ==> -=\n",lineno); }
                   
                   | LEFT_SHIFT_ASSIGN  
                   { printf("Line Number: %d  | Production: assignment_operator ==> <<=\n",lineno); }
                   
                   | RIGHT_SHIFT_ASSIGN  
                   { printf("Line Number: %d  | Production: assignment_operator ==> >>=\n",lineno); }
                   
                   | BITWISE_AND_ASSIGN  
                   { printf("Line Number: %d  | Production: assignment_operator ==> &=\n",lineno); }
                   
                   | BITWISE_XOR_ASSIGN  
                   { printf("Line Number: %d  | Production: assignment_operator ==> ^=\n",lineno); }
                   
                   | BITWISE_OR_ASSIGN 
                   { printf("Line Number: %d  | Production: assignment_operator ==> |=\n",lineno); }
                   ;

expression: assignment_expression
          { printf("Line Number: %d  | Production: expression ==> assignment_expression\n",lineno); }
          
          | expression COMMA assignment_expression
          { printf("Line Number: %d  | Production: expression ==> expression , assignment_expression\n",lineno); }
          ;

constant_expression: conditional_expression
                   { printf("Line Number: %d  | Production: constant_expression ==> conditional_expression\n",lineno); }
                   ;


declaration: declaration_specifiers init_declarator_listopt SEMI_COLON
           { printf("Line Number: %d  | Production: declaration ==> declaration_specifiers init_declarator_list_opt ;\n",lineno); }
           ;

init_declarator_listopt: init_declarator_list
                       { printf("Line Number: %d  | Production: init_declarator_list_opt ==> init_declarator_list\n",lineno); }
                       
                       |
                       { printf("Line Number: %d  | Production: init_declarator_list_opt ==> Epsilon \n",lineno); }
                       ;

declaration_specifiers: storage_class_specifier declaration_specifiersopt
                      { printf("Line Number: %d  | Production: declaration_specifiers ==> storage_class_specifier declaration_specifiers_opt\n",lineno); }
                      
                      | type_specifier declaration_specifiersopt
                      { printf("Line Number: %d  | Production: declaration_specifiers ==> type_specifier declaration_specifiers_opt\n",lineno); }
                      
                      | type_qualifier declaration_specifiersopt
                      { printf("Line Number: %d  | Production: declaration_specifiers ==> type_qualifier declaration_specifiers_opt\n",lineno); }
                      
                      | function_specifier declaration_specifiersopt
                      { printf("Line Number: %d  | Production: declaration_specifiers ==> function_specifier declaration_specifiers_opt\n",lineno); }
                      ;

declaration_specifiersopt: declaration_specifiers
                         { printf("Line Number: %d  | Production: declaration_specifiers_opt ==> declaration_specifiers\n",lineno); }
                         
                         |
                         { printf("Line Number: %d  | Production: declaration_specifiers_opt ==> Epsilon\n",lineno); }
                         ;

init_declarator_list: init_declarator
                    { printf("Line Number: %d  | Production: init_declarator_list ==> init_declarator\n",lineno); }
                    
                    | init_declarator_list COMMA init_declarator
                    { printf("Line Number: %d  | Production: init_declarator_list ==> init_declarator_list , init_declarator\n",lineno); }
                    ;

init_declarator: declarator
               { printf("Line Number: %d  | Production: init_declarator ==> declarator\n",lineno); }
               
               | declarator ASSIGN  initializer
               { printf("Line Number: %d  | Production: init_declarator ==> declarator = initializer\n",lineno); }
               ;


storage_class_specifier: EXTERN
                       { printf("Line Number: %d  | Production: storage_class_specifier ==> EXTERN\n",lineno); }
                       
                       | STATIC
                       { printf("Line Number: %d  | Production: storage_class_specifier ==> STATIC\n",lineno); }
                       
                       | AUTO
                       { printf("Line Number: %d  | Production: storage_class_specifier ==> AUTO\n",lineno); }
                       
                       | REGISTER
                       { printf("Line Number: %d  | Production: storage_class_specifier ==> REGISTER\n",lineno); }
                       ;

type_specifier: VOID
              { printf("Line Number: %d  | Production: type_specifier ==> VOID\n",lineno); }
              
              | CHAR
              { printf("Line Number: %d  | Production: type_specifier ==> CHAR\n",lineno); }
              
              | SHORT
              { printf("Line Number: %d  | Production: type_specifier ==> SHORT\n",lineno); }
              
              | INT
              { printf("Line Number: %d  | Production: type_specifier ==> INT\n",lineno); }
              
              | LONG
              { printf("Line Number: %d  | Production: type_specifier ==> LONG\n",lineno); }
              
              | FLOAT
              { printf("Line Number: %d  | Production: type_specifier ==> FLOAT\n",lineno); }
              
              | DOUBLE
              { printf("Line Number: %d  | Production: type_specifier ==> DOUBLE\n",lineno); }
              
              | SIGNED
              { printf("Line Number: %d  | Production: type_specifier ==> SIGNED\n",lineno); }
              
              | UNSIGNED
              { printf("Line Number: %d  | Production: type_specifier ==> UNSIGNED\n",lineno); }
              
              | _BOOL
              { printf("Line Number: %d  | Production: type_specifier ==> _BOOL\n",lineno); }
              
              | _COMPLEX
              { printf("Line Number: %d  | Production: type_specifier ==> _COMPLEX\n",lineno); }
              
              | _IMAGINARY
              { printf("Line Number: %d  | Production: type_specifier ==> _IMAGINARY\n",lineno); }
              
              | enum_specifier
              { printf("Line Number: %d  | Production: type_specifier ==> enum_specifier\n",lineno); }
              ;

specifier_qualifier_list: type_specifier specifier_qualifier_listopt
                        { printf("Line Number: %d  | Production: specifier_qualifier_list ==> type_specifier specifier_qualifier_list_opt\n",lineno); }
                        
                        | type_qualifier specifier_qualifier_listopt
                        { printf("Line Number: %d  | Production: specifier_qualifier_list ==> type_qualifier specifier_qualifier_list_opt\n",lineno); }
                        ;

specifier_qualifier_listopt: specifier_qualifier_list
                           { printf("Line Number: %d  | Production: specifier_qualifier_list_opt ==> specifier_qualifier_list\n",lineno); }
                           
                           |
                           { printf("Line Number: %d  | Production: specifier_qualifier_list_opt ==> Epsilon\n",lineno); }
                           ;

enum_specifier: ENUM identifieropt LEFT_CURLY enumerator_list RIGHT_CURLY
              { printf("Line Number: %d  | Production: enum_specifier ==> ENUM identifier_opt { enumerator_list }\n",lineno); }
              
              | ENUM identifieropt LEFT_CURLY enumerator_list COMMA RIGHT_CURLY
              { printf("Line Number: %d  | Production: enum_specifier ==> ENUM identifier_opt { enumerator_list , }\n",lineno); }
              
              | ENUM IDENTIFIER
              { printf("Line Number: %d  | Production: enum_specifier ==> ENUM \n",lineno); printf("\t IDENTIFIER Value: %s\n",$2);}
              ;

identifieropt: IDENTIFIER
             { printf("Line Number: %d  | Production: identifier_list ==> IDENTIFIER\n",lineno); printf("\t IDENTIFIER Value: %s\n",$1);}
             
             | 
             { printf("Line Number: %d  | Production: identifier_list ==> Epsilon\n",lineno); }
             ;

enumerator_list: enumerator
               { printf("Line Number: %d  | Production: enumerator_list ==> enumerator\n",lineno); }
               
               | enumerator_list COMMA enumerator
               { printf("Line Number: %d  | Production: enumerator_list ==> enumerator_list , enumerator\n",lineno); }
               ;

enumerator: IDENTIFIER
          { printf("Line Number: %d  | Production: enumerator ==> IDENTIFIER\n",lineno); }
          
          | IDENTIFIER ASSIGN  constant_expression
          { printf("Line Number: %d  | Production: enumerator ==> IDENTIFIER = constant_expression\n",lineno); printf("\t IDENTIFIER Value: %s\n", $1);}
          ;

type_qualifier: CONST
              { printf("Line Number: %d  | Production: type_qualifier ==> CONST\n",lineno); }
              
              | RESTRICT
              { printf("Line Number: %d  | Production: type_qualifier ==> RESTRICT\n",lineno); }
              
              | VOLATILE
              { printf("Line Number: %d  | Production: type_qualifier ==> VOLATILE\n",lineno); }
              ;

function_specifier: INLINE
                  { printf("Line Number: %d  | Production: function_specifier ==> INLINE\n",lineno); }
                  ;

declarator: pointeropt direct_declarator
          { printf("Line Number: %d  | Production: declarator ==> pointer_opt direct_declarator\n",lineno); }
          ;

pointeropt: pointer
          { printf("Line Number: %d  | Production: pointer_opt ==> pointer\n",lineno); }
          
          |
          { printf("Line Number: %d  | Production: pointer_opt ==> Epsilon \n",lineno); }
          ;

direct_declarator: IDENTIFIER
                 { printf("Line Number: %d  | Production: direct_declarator ==> IDENTIFIER\n",lineno); printf("\tIDENTIFIER Value: %s\n",$1);}
                 
                 | LEFT_PARENTHESES declarator RIGHT_PARENTHESES
                 { printf("Line Number: %d  | Production: direct_declarator ==> ( declarator )\n",lineno); }
                 
                 | direct_declarator LEFT_SQUARE type_qualifier_listopt assignment_expressionopt RIGHT_SQUARE
                 { printf("Line Number: %d  | Production: direct_declarator ==> direct_declarator [ type_qualifier_list_opt assignment_expression_opt ]\n",lineno); }
                 
                 | direct_declarator LEFT_SQUARE STATIC type_qualifier_listopt assignment_expression RIGHT_SQUARE
                 { printf("Line Number: %d  | Production: direct_declarator ==> direct_declarator [ STATIC type_qualifier_list_opt assignment_expression ]\n",lineno); }
                 
                 | direct_declarator LEFT_SQUARE type_qualifier_list STATIC assignment_expression RIGHT_SQUARE
                 { printf("Line Number: %d  | Production: direct_declarator ==> direct_declarator [ type_qualifier_list STATIC assignment_expression ]\n",lineno); }
                 
                 | direct_declarator LEFT_SQUARE type_qualifier_listopt MUL RIGHT_SQUARE
                 { printf("Line Number: %d  | Production: direct_declarator ==> direct_declarator [ type_qualifier_list_opt * ]\n",lineno); }
                 
                 | direct_declarator LEFT_PARENTHESES parameter_type_list RIGHT_PARENTHESES
                 { printf("Line Number: %d  | Production: direct_declarator ==> direct_declarator ( parameter_type_list )\n",lineno); }
                 
                 | direct_declarator LEFT_PARENTHESES identifier_listopt RIGHT_PARENTHESES
                 { printf("Line Number: %d  | Production: direct_declarator ==> direct_declarator ( identifier_list_opt )\n",lineno); }
                 ;

type_qualifier_listopt: type_qualifier_list
                      { printf("Line Number: %d  | Production: type_qualifier_list_opt ==> type_qualifier_list\n",lineno); }
                      
                      | 
                      { printf("Line Number: %d  | Production: type_qualifier_list_opt ==> Epsilon \n",lineno); }
                      ;

assignment_expressionopt: assignment_expression
                        { printf("Line Number: %d  | Production: assignment_expression_opt ==> assignment_expression\n",lineno); }
                        
                        |
                        { printf("Line Number: %d  | Production: assignment_expression_opt ==> Epsilon\n",lineno); }
                        ;


identifier_listopt: identifier_list
                  { printf("Line Number: %d  | Production: identifier_list_opt ==> identifier_list\n",lineno); }
                  
                  |
                  { printf("Line Number: %d  | Production: identifier_list_opt ==> Epsilon \n",lineno); }
                  ;

pointer: MUL type_qualifier_listopt
       { printf("Line Number: %d  | Production: pointer ==> * type_qualifier_list_opt\n",lineno); }
       
       | MUL type_qualifier_listopt pointer
       { printf("Line Number: %d  | Production: pointer ==> * type_qualifier_list_opt pointer\n",lineno); }
       ;


type_qualifier_list: type_qualifier
                   { printf("Line Number: %d  | Production: type_qualifier_list ==> type_qualifier\n",lineno); }
                   | type_qualifier_list type_qualifier
                   { printf("Line Number: %d  | Production: type_qualifier_list ==> type_qualifier_list type_qualifier\n",lineno); }
                   ;

parameter_type_list: parameter_list
                   { printf("Line Number: %d  | Production: parameter_type_list ==> parameter_list\n",lineno); }
                   
                   | parameter_list COMMA ELLIPSIS
                   { printf("Line Number: %d  | Production: parameter_type_list ==> parameter_list , ...\n",lineno); }
                   ;


parameter_list: parameter_declaration
              { printf("Line Number: %d  | Production: parameter_list ==> parameter_declaration\n",lineno); }
              
              | parameter_list COMMA parameter_declaration
              { printf("Line Number: %d  | Production: parameter_list ==> parameter_list , parameter_declaration\n",lineno); }
              ;

parameter_declaration: declaration_specifiers declarator
                     { printf("Line Number: %d  | Production: parameter_declaration ==> declaration_specifiers declarator\n",lineno); }
                     
                     | declaration_specifiers
                     { printf("Line Number: %d  | Production: parameter_declaration ==> declaration_specifiers \n",lineno); }
                     ;

identifier_list: IDENTIFIER
               { printf("Line Number: %d  | Production: identifier_list ==> IDENTIFIER\n",lineno); printf("\t IDENTIFIER Value: %s\n", $1);}
               
               | identifier_list COMMA IDENTIFIER
               { printf("Line Number: %d  | Production: identifier_list ==> identifier_list , IDENTIFIER\n",lineno); printf("\t IDENTIFIER Value: %s\n", $3);}
               ;

type_name: specifier_qualifier_list
         { printf("Line Number: %d  | Production: type_name ==> specifier_qualifier_list \n",lineno); }
         ;


initializer: assignment_expression
           { printf("Line Number: %d  | Production: initializer ==> assignment_expression \n",lineno); }
           
           | LEFT_CURLY initializer_list RIGHT_CURLY
           { printf("Line Number: %d  | Production: initializer ==> { initializer_list } \n",lineno); }
           
           | LEFT_CURLY initializer_list COMMA RIGHT_CURLY
           { printf("Line Number: %d  | Production: initializer ==> { initialiser_list , } \n",lineno); }
           ;

initializer_list: designationopt initializer
                { printf("Line Number: %d  | Production: initializer_list ==> designation_opt initializer \n",lineno); }
                
                | initializer_list COMMA designationopt initializer
                { printf("Line Number: %d  | Production: initializer_list ==> initialiser_list , designation_opt initialiser_list \n",lineno); }
                ;

designationopt: designation
              { printf("Line Number: %d  | Production: designation_opt ==> designation \n",lineno); }
              
              |
              { printf("Line Number: %d  | Production: designation_opt ==> Epsilon \n",lineno); }
              ;

designation: designator_list ASSIGN 
           { printf("Line Number: %d  | Production: designation ==> designator_list = \n",lineno); }
           ;

designator_list: designator
               { printf("Line Number: %d  | Production: designator_list ==> designator \n",lineno); }
               
               | designator_list designator
               { printf("Line Number: %d  | Production: designator_list ==> designator_list designator \n",lineno); }
               ;

designator: LEFT_SQUARE constant_expression RIGHT_SQUARE
          { printf("Line Number: %d  | Production: designator ==> [ constant_expression ] \n",lineno); }
          
          | DOT IDENTIFIER
          { printf("Line Number: %d  | Production: designator ==> . IDENTIFIER \n",lineno);printf("\t IDENTIFIER Value: %s\n", $2); }
          ;

statement: labeled_statement
         { printf("Line Number: %d  | Production: statement ==> labeled_statement \n",lineno); }
         
         | compound_statement
         { printf("Line Number: %d  | Production: statement ==> compound_statement \n",lineno); }
         
         | expression_statement
         { printf("Line Number: %d  | Production: statement ==> expression_statement \n",lineno); }
         
         | selection_statement
         { printf("Line Number: %d  | Production: statement ==> selection_statement \n",lineno); }
         
         | iteration_statement
         { printf("Line Number: %d  | Production: statement ==> iteration_statement \n",lineno); }
         
         | jump_statement
         { printf("Line Number: %d  | Production: statement ==> jump_statement \n",lineno); }
         ;

labeled_statement: IDENTIFIER COLON statement
                 { printf("Line Number: %d  | Production: labeled_statement ==> IDENTIFIER \n",lineno);printf("\t IDENTIFIER Value: %s\n", $1); }
                 
                 | CASE constant_expression COLON statement
                 { printf("Line Number: %d  | Production: labeled_statement ==> CASE constant_expression : statement \n",lineno); }
                 
                 | DEFAULT COLON statement
                 { printf("Line Number: %d  | Production: labeled_statement ==> DEFAULT : statement \n",lineno); }
                 ;

compound_statement: LEFT_CURLY block_item_listopt RIGHT_CURLY
                  { printf("Line Number: %d  | Production: compound_statement ==> { block_item_list_opt } \n",lineno); }
                  ;

block_item_listopt: block_item_list
                  { printf("Line Number: %d  | Production: block_item_list_opt ==> block_item_list \n",lineno); }
                  |
                  { printf("Line Number: %d  | Production: block_item_list_opt ==> Epsilon \n",lineno); }
                  ;

block_item_list: block_item
               { printf("Line Number: %d  | Production: block_item_list ==> block_item \n",lineno); }
               
               | block_item_list block_item
               { printf("Line Number: %d  | Production: block_item_list ==> block_item_list block_item \n",lineno); }
               ;

block_item: declaration
          { printf("Line Number: %d  | Production: block_item ==> declaration \n",lineno); }
          | statement
          { printf("Line Number: %d  | Production: block_item ==> statement \n",lineno); }
          ;

expression_statement: expressionopt SEMI_COLON
                    { printf("Line Number: %d  | Production: expression_statement ==> expression_opt ; \n",lineno); }
                    ;

expressionopt: expression
             { printf("Line Number: %d  | Production: expression_opt ==> expression \n",lineno); }
             |
             { printf("Line Number: %d  | Production: expression_opt ==> Epsilon \n",lineno); }
             ;

selection_statement: IF LEFT_PARENTHESES expression RIGHT_PARENTHESES statement
                   { printf("Line Number: %d  | Production: selection_statement ==> IF ( expression ) statement \n",lineno); }
                   
                   | IF LEFT_PARENTHESES expression RIGHT_PARENTHESES statement ELSE statement 
                   { printf("Line Number: %d  | Production: selection_statement ==> IF ( expression ) statement ELSE statement \n",lineno); }
                   
                   | SWITCH LEFT_PARENTHESES expression RIGHT_PARENTHESES statement
                   { printf("Line Number: %d  | Production: selection_statement ==> SWITCH ( expression ) statement  \n",lineno); }
                   ;

iteration_statement: WHILE LEFT_PARENTHESES expression RIGHT_PARENTHESES statement
                   { printf("Line Number: %d  | Production: iteration_statement ==> WHILE ( expression ) statement \n",lineno); }

                   | DO statement WHILE LEFT_PARENTHESES expression RIGHT_PARENTHESES SEMI_COLON
                   { printf("Line Number: %d  | Production: iteration_statement ==> DO statement WHILE ( expression ) ; \n",lineno); }

                   | FOR LEFT_PARENTHESES expressionopt SEMI_COLON expressionopt SEMI_COLON expressionopt RIGHT_PARENTHESES statement
                   { printf("Line Number: %d  | Production: iteration_statement ==> FOR ( expressionopt ; expressionopt ; expressionopt ) statement \n",lineno); }

                   | FOR LEFT_PARENTHESES declaration expressionopt SEMI_COLON expressionopt RIGHT_PARENTHESES statement
                   { printf("Line Number: %d  | Production: iteration_statement ==> FOR ( declaration expression_opt ; expression_opt ) statement \n",lineno); }
                   ;

jump_statement: GOTO IDENTIFIER SEMI_COLON
              { printf("Line Number: %d  | Production: jump_statement ==> GOTO IDENTIFIER ; \n",lineno);printf("\t IDENTIFIER Value: %s\n", $2); }
              
              | CONTINUE SEMI_COLON
              { printf("Line Number: %d  | Production: jump_statement ==> CONTINUE ; \n",lineno); }

              | BREAK SEMI_COLON
              { printf("Line Number: %d  | Production: jump_statement ==> BREAK ; \n",lineno); }
              
              | RETURN expressionopt SEMI_COLON
              { printf("Line Number: %d  | Production: jump_statement ==>  RETURN expressionopt ;\n",lineno); }
              ;

translation_unit: external_declaration
                { printf("Line Number: %d  | Production: translation_unit ==> external_declaration \n",lineno); }
                | translation_unit external_declaration
                { printf("Line Number: %d  | Production: translation_unit ==> translation_unit external_declaration \n",lineno); }
                ;

external_declaration: function_definition
                    { printf("Line Number: %d  | Production: external_declaration ==> function_definition \n",lineno); }
                    
                    | declaration
                    { printf("Line Number: %d  | Production: external_declaration ==> declaration \n",lineno); }
                    ;

function_definition: declaration_specifiers declarator declaration_listopt compound_statement
                   { printf("Line Number: %d  | Production: function_definition ==> declaration_specifiers declarator declaration_list_opt compound_statement \n",lineno); }
                   ;

declaration_listopt: declaration_list
                   { printf("Line Number: %d  | Production: declaration_list_opt ==> declaration_list \n",lineno); }
                   
                   |
                   { printf("Line Number: %d  | Production: declaration_list_opt ==> Epsilon \n",lineno); }
                   ;

declaration_list: declaration
                { printf("Line Number: %d  | Production: declaration_list ==> declaration \n",lineno); }
                   
                | declaration_list declaration
                { printf("Line Number: %d  | Production: declaration_list ==> declaration_list declaration \n",lineno); }
                   
                ;
                
%%

void yyerror(char* s) {
    printf("Error in Line Number: %d ( %s )\n", lineno, s);
}