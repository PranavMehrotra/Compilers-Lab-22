// pointers
void swap(int *xp, int *yp) {                      // pointers
    if(xp != NULL && yp != NULL)
    {
        int temp = *xp;
        *xp = *yp;
        *yp = temp;
    }
    return;
}

int main() {
    int i=0;
    while(i<5)
    {
        i=i+1;
    }

    do
    {
        i=i-1;
    } while(i>=0);

    return 0;
}
