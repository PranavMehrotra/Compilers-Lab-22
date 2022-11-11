// This program tests function declaration, calling, global variable scope, some operators : +, -, etc. 
// Checks basic statements, expression, readInt and printInt library functions created earlier
// Also checks the recursive fibonacci function to check the function call and return methodology
int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);

int global_count = 0;                         // Testing global variable
int count = 0;

int fac (int n);                           // Testing function declaration

int main () {
    count++;
    global_count = count;
    int n, flag;
    printStr("Enter n (n < 20): ");
    n = readInt(&flag);
    int i;
    int factorial[100];

    // for loop to print the fibonacci series.
    for (i = 0; i < n; i++) {
        factorial[i] = fac(i+1);
        count++;
        global_count = count;
    }
    for (i = 0; i < n; i++) {
        printStr("factorial[");
        printInt(i + 1);
        printStr("] = ");
        printInt(factorial[i]);
        printStr("\n");
    }
    return 0;
}

int fac (int n) {
    count++;
    global_count = count;

    if (n <= 1) {
        return 1;
    }
 
    // Testing recursive function
    else {
        return fac(n - 1)*n;
    }
}
