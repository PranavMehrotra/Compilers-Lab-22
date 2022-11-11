// Include predefined functions 
int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);

// Function for the implementation of Kadane's Algorithm
int max_sub_array_sum (int a[], int n) {                 // Array as parameter                 
    int overall_max = -1000000, max_till_now = 0; 
    int i;
    for (i = 0; i < n; i++) { 
        max_till_now = max_till_now + a[i]; 
        if (overall_max < max_till_now) {
            overall_max = max_till_now; 
        }
  
        if (max_till_now < 0) {
            max_till_now = 0; 
        }
    } 
    return overall_max; 
} 
  
// Driver program to test maxSubArrSum
int main() { 
    int a[8];
    a[0]= -12;
    a[1]= -87;
    a[2]= 23;
    a[3]= -6;
    a[4]= -43;
    a[5]= 320;
    a[6]= 233;
    a[7]= -87;
    int max_subArr_sum = max_sub_array_sum(a, 8);        // Passing array as argument
    printStr("Maximum sum of a contiguous sub array: ");
    printInt(max_subArr_sum);
    printStr("\n");
    return 0; 
}
