#include <stdio.h>
extern int yyparse();

int main() {
    printf("\n-------------------------------------------------------- Line no: 1 --------------------------------------------------------\n");
    yyparse();
    return 0;
}
