#include "stdio.h"
#include "string.h"

// this file creates a simple exe on the cRIO to test the LabVIEW interface lib
// to compile, run:
// gcc -L/usr/local/lib/libCallROSCO -o testCInterface main.c -lCallROSCO

// make sure libs can be found: export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

// interface into lib for LabVIEW.
extern int callROSCO(float *inarr, int *aviFAIL, char *inputStr, char *infileName, char *outfileName);

#define SWAP_SIZE 200
#define MSG_SIZE 16384

#define C2F 1 // Arrays in C are zero based, FORTRAN is 1 based.
#define INDEX_DT 3 - C2F

int main(void)
{
    float swap[SWAP_SIZE] = {};
    char msg[MSG_SIZE];
    int ret;
    int fail;

    char infileName[] = "/C/rosco-data/DISCON-UMaineSemi.IN";
    char outfileName[] = "/C/rosco-data/SimOut.txt";

    swap[INDEX_DT] = 0.001; // set this to non-zero (ROSCO fails otherwise)

    printf("Calling ROSCO C-Interface ...\n");

    ret = callROSCO(swap, &fail, msg, infileName, outfileName);

    printf("Finished calling ROSCO C-Interface. Avi fail = %i, msg = %s. Ret = %i\n", fail, msg, ret);

    return 0;
}
