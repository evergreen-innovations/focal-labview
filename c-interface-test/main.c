#include "stdio.h"

// this file creates a simple exe on the cRIO to test the LabVIEW interface lib
// to compile, run:
// gcc -L/usr/local/lib/libCallROSCO -o testCInterface main.c -lCallROSCO

// make sure libs can be found: export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

// interface into lib for LabVIEW.
extern int callROSCO(float *inarr, int *aviFAIL, char *inputStr);

int main(void)
{
    float swap[200] = {};
    int fail;
    char msg[16384];
    int ret;

    printf("Calling ROSCO C-Interface ...\n");

    ret = callROSCO(swap, &fail, msg);

    printf("Finished calling ROSCO C-Interface. Avi fail = %i, msg = %s. Ret = %i\n", fail, msg, ret);

    return 0;
}
