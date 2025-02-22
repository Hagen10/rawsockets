#include <stdio.h>
#include <unistd.h>

int main() {
    while (1)
    {
        printf("Hello, World!\n");
        fflush(stdout);
        sleep(5);
    }
    return 0;
}