#include "stdio.h"
#include "string.h"

// to compile:
// gcc -fPIC -shared -L/usr/local/lib/libROSCO -o libCallROSCO.so callROSCO.c -lROSCO
// mv libCallROSCO.so /usr/local/lib

#define MSG_SIZE 16384

#define C2F 1 // Arrays in C are zero based, FORTRAN is 1 based.
#define INDEX_IN_FILE_LEN 50 - C2F
#define INDEX_OUT_FILE_LEN 51 - C2F
#define INDEX_AVCMSG_SIZE 49 - C2F

// interface into the FORTRAN compiled .so file
extern void DISCON(float *avrSWAP, int *aviFAIL, char *accINFILE, char *avcOUTNAME, char *avcMSG);

// interface for LabVIEW to call
int callROSCO(float *swap, int *aviFAIL, char *inputStrHndl, char *infileName, char *outfileName)
{

	// create mem for return message to LabVIEW
	char avcMSG[MSG_SIZE];

	// calculate input and output file name length for ROSCO
	swap[INDEX_IN_FILE_LEN] = (float)strlen(infileName);
	swap[INDEX_OUT_FILE_LEN] = (float)strlen(outfileName);

	// fix the length of the return message
	swap[INDEX_AVCMSG_SIZE] = (float)MSG_SIZE;

	// call into ROSCO lib
	DISCON(swap, aviFAIL, infileName, outfileName, avcMSG);

	// copy the return message string
	strcpy(inputStrHndl, avcMSG);
	memset(avcMSG, '\0', MSG_SIZE);

	return 0;
}

// test function for LabVIEW to call (does not require ROSCO lib)
float add(float a, float b)
{
	return a + b;
}