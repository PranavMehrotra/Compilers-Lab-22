int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);


int main() {
    int loop_count = 1;
    do {                                    // Testing do while loop
        printStr("Entered for iteration ");
        printInt(loop_count++);            // Incrementor in printStr
        printStr("\n");
    } while (loop_count < 10);

    // Scope management 
    { 
        int p = 32;
        printStr("\nScope 1: ");
        printInt(p);
        { 
            int p = 27;
            printStr("\nScope 2: ");
            printInt(p);
            { 
                int p = 13;
                if (p == 13) {
                    printStr("\nEntered in the p == 13 condition if block.");
                }
                printStr("\nScope 3: ");
                printInt(p);
                printStr("\n");
            }
        }
    }
    return 0;
}