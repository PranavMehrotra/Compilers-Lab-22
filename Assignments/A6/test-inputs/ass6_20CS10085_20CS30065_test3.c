int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);

// Global declarations
int a = 23, *p, b;               // pointer declaration
int w[7];                      // 1D array declaration
char c; 
int i, j, k, l, m;
float d = 7.7;

int main () {
    int x;                      // Variable Declarations
    int y;
    int flag;
    printStr("Enter x: ");
    x = readInt(&flag);
    printStr("Enter y: ");
    y = readInt(&flag);
    char ch = 'c';              // Character definitions

    // Arithmetic Operators
    i = x + y;                  // Addition  
    printStr("i = x + y = ");
    printInt(i);
    printStr("\n");

    j = x - y;                  // Subtraction
    printStr("j = x - y = ");
    printInt(j);
    printStr("\n");

    k = x * y;                  // Multiplication
    printStr("k = x * y = ");
    printInt(k);
    printStr("\n");

    l = x / y;                  // Division
    printStr("l = x / y = ");
    printInt(l);
    printStr("\n");

    m = x % y;                  // Modulo
    printStr("m = x % y = ");
    printInt(m);
    printStr("\n");

    return 0;
}