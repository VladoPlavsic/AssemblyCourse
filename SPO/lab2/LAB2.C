#include <stdio.h>

int add(int *a, int *b){
    int result = *a + *b;
    return result;
}

int main(){
    
    int a = 2, b = 3;
    int result = add(&a,&b);
  
    printf("%d",result);

    return 1;

}
