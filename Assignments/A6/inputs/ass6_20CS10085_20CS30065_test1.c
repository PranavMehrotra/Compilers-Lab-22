// This test checks basic statements, expression, readInt and printInt library functions created earlier
// Also it checks the recursive factorial function to check the function call and return methodology
int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);

int global_count = 0;                         // Testing global variables
int count = 0;

int fac (int n);                           // Testing function declaration

int main () {
    count++;
    global_count = count;
    int n, flag;
    printStr("Enter n (n < 16): ");
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

// Function definition
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
