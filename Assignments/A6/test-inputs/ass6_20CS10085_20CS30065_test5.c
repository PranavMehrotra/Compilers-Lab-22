// Testing various functionalities through merge sort

int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);

int merge(int a[], int l, int mid, int r); 

void merge_sort (int a[], int l, int r) {      // Testing void return type
    if (l < r) {
        int m = (l + r) / 2; 
        merge_sort(a, l, m);                   // Testing recursion
        merge_sort(a, m + 1, r);
        merge(a, l, m, r);
    }
}

void print_arr (int a[], int n) {
    int i;
    for (i = 0; i < n; i++) {
        printInt(a[i]);
        printStr(" ");
    }
    printStr("\n");
}
 
int main() {
    printStr("Merge Sort\n");
    
    int n = 6;
    int a[6];
    a[0] = 123;
    a[1] = 1;
    a[2] = 34;
    a[3] = 3212;
    a[4] = 344;
    a[5] = 2;
 
    printStr("Original array: \n");
    print_arr(a, n);
 
    merge_sort(a, 0, n - 1);
 
    printStr("Sorted array: \n");
    print_arr(a, n);

    return 0;
}

int merge (int a[], int l, int mid, int r) {    // Passing array as parameter
    int i, j, k;
    int n1 = mid - l + 1;
    int n2 =  r - mid; 
    int left[6], right[6];
 
    for(i = 0; i < n1; i++) {
        left[i] = a[l + i];
    }
    for(j = 0; j < n2; j++) {
        int q = mid + j + 1;
        right[j] = a[q];
    }
 
    i = 0;
    j = 0;
    k = l;
    while (i < n1 && j < n2) {                  // Testing while loop
        if (left[i] <= right[j]) {
            a[k] = left[i];
            i++;
        }
        else {
            a[k] = right[j];
            j++;
        }
        k++;
    }
 
    while (i < n1) {
        a[k] = left[i];
        i++;
        k++;
    }
 
    while (j < n2) {
        a[k] = right[j];
        j++;
        k++;
    }

    return 0;
}
