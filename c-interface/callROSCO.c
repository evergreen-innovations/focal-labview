#include "stdio.h"
#include "string.h"
#include "stdlib.h"

// to compile on cRIO:
// gcc -Wall -fmessage-length=0 -fPIC -shared -L/usr/local/lib -o libCallROSCO.so callROSCO.c -lROSCO
// mv libCallROSCO.so /usr/local/lib

// to compile on MacOS:
// gcc -fPIC -shared -L/usr/local/lib -o libCallROSCO.so callROSCO.c -ldiscon
// sudo mv libCallROSCO.so /usr/local/lib

#define C2F 1 // Arrays in C are zero based, FORTRAN is 1 based.
#define INDEX_TIME 2 - C2F
#define INDEX_IN_FILE_LEN 50 - C2F
#define INDEX_OUT_FILE_LEN 51 - C2F
#define INDEX_AVCMSG_SIZE 49 - C2F
#define INDEX_NUM_BL 61 - C2F

#define MSG_SIZE 4096
#define BUF_SIZE 8192

// interface into the FORTRAN compiled .so file
extern void DISCON(float *avrSWAP, int *aviFAIL, char *accINFILE, char *avcOUTNAME, char *avcMSG);

// interface for LabVIEW to call

char msg[MSG_SIZE]; // one extra for the C null char
char buf[BUF_SIZE];

int callROSCO(float *swap, int *aviFAIL, char *msgIn, char *infileName, char *outfileName)
{
	float time;

	// calculate input and output file name length for ROSCO
	swap[INDEX_IN_FILE_LEN] = (float)strlen(infileName);
	swap[INDEX_OUT_FILE_LEN] = (float)strlen(outfileName);
	swap[INDEX_AVCMSG_SIZE] = (float)MSG_SIZE;
	swap[INDEX_NUM_BL] = 3;

	// call into ROSCO lib
	DISCON(swap, aviFAIL, infileName, outfileName, msg);

	time = swap[INDEX_TIME];

	if (*aviFAIL != 0)
	{
		sprintf(buf, "LabVIEW RT to ROSCO interface v0.32.\n\nReceived at total of %i chars from ROSCO.\n\n AVIFail = %i\n\nContent %s", (int)strlen(msg), *aviFAIL, msg);
	}
	else
	{
		sprintf(buf, "LabVIEW RT to ROSCO interface v0.32.\n\nSuccesfully called interface at t = %f", time);
	}

	strcpy(msgIn, buf);

	memset(msg, '\0', MSG_SIZE);
	memset(buf, '\0', BUF_SIZE);

	return 0;
}

// test function for LabVIEW to call (does not require ROSCO lib)
float add(float a, float b)
{
	return a + b;
}