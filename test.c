#sysroot/bin/clang -target x86_64-linux-llvm ./test.c  -static

#include <stdio.h>

int main(){printf("hello world!\n"); return 0;}
