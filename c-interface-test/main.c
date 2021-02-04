#include "stdio.h"
#include "string.h"

// this file creates a simple exe on the cRIO to test the LabVIEW interface lib
// to compile on cRIO, run:
// gcc -L/usr/local/lib -o testCInterface main.c -lCallROSCO

// to compile on MacOS:
// gcc -L/usr/local/lib -o testCInterface main.c -lCallROSCO

// make sure libs can be found: export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

// interface into lib for LabVIEW.
extern int callROSCO(double *swap, int *aviFAIL, char *msgIn, char *infileName, char *outfileName);
extern float add(float, float);

#define SWAP_SIZE 500
#define STEPS 20

#define MSG_SIZE 8192

#define C2F 1 // Arrays in C are zero based, FORTRAN is 1 based.
#define INDEX_ISTATUS 1 - C2F
#define INDEX_TIME 2 - C2F
#define INDEX_DT 3 - C2F
#define INDEX_AVCMSG_SIZE 49 - C2F
#define INDEX_NUM_BL 61 - C2F
#define INDEX_GEN_SPEED 20 - C2F
#define INDEX_ROT_SPEED 21 - C2F
#define INDEX_HorWindV 27 - C2F

int main(void)
{

    int ret;
    int fail, iStatus;
    float a, b, sum;

    double dt = 0.1;
    a = 1.0;
    b = 2.0;
    fail = -100;

    char infileName[] = "/C/rosco-data/DISCON-UMaineSemi.IN";
    char outfileName[] = "/C/rosco-data/SimOut.txt";

    printf("Float size = %u\n ", sizeof(float));

    printf("Calling test function add\n");
    sum = add(a, b);
    printf("Result of %f + %f = %f \n\n", a, b, sum);

    // fix the length of the return message
    double swap[SWAP_SIZE] = {};

    swap[INDEX_AVCMSG_SIZE] = (double)MSG_SIZE;
    swap[INDEX_NUM_BL] = 3;

    for (int i = 0; i <= STEPS; i++)
    {
        char msg[MSG_SIZE];
        if (i == 0)
        {
            iStatus = 0;
            swap[INDEX_HorWindV] = 5;
        }
        else
        {
            iStatus = 1;
        }

        swap[INDEX_ISTATUS] = iStatus;
        swap[INDEX_TIME] = (double)i * dt;
        swap[INDEX_DT] = dt;

        if (i > 2)
        {
            swap[INDEX_GEN_SPEED] = 1; // rad/s
            swap[INDEX_ROT_SPEED] = 1;
        }

        printf("V0.10 Calling ROSCO C-Interface step %u of %u ...\n", i, STEPS);
        ret = callROSCO(swap, &fail, msg, infileName, outfileName);
        printf("V0.10 Finished calling ROSCO C-Interface. Avi fail = %i, msg = %s. Ret = %i\n\n", fail, msg, ret);
    }

    return 0;
}