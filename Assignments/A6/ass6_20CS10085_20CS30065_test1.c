//test file for declarators and function calling

float fl = 2.3;                     // float value declarator
char ch;	                        // character with no initialization
int i, j, k;                        // int variables
int arr_1[10];                      // 1D int array 
float arr_2[20][50];                // 2D float array 
char arr_3[2][2];                   // 2D char array
int *a;                             // pointer declaration
char *string;                       //character array

void void_func()                    //function with no parameter declaration
{   
    string = "void function";
}

float func_f(float a)               //function with parameters
{
    return a+1;
}

int main () {
    int x = 2020;
    int y = 2021;
    int ans[9];

    ans[0] = x;                     //arithmetic operations
    ans[1] = x + y;
    ans[2] = x - y;
    ans[3] = x * y;
    ans[4] = x / y;
    ans[5] = x % y;
    ans[6] = x ^ y;
    ans[7] = x | y;
    ans[8] = x & y;

    return 0;
}
