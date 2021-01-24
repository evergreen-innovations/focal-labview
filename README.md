# FOCAL LabVIEW Control Code and ROSCO interface

## Overview
The FOCAL LabVIEW code integrates with the NREL ROSCO controller. The ROSCO controller is written in FORTRAN. To use this controller in LabVIEW RT on the cRIO, a number of setup steps are required on the cRIO. This includes both C and FORTRAN compilers as outlined below.

## Installing gcc on the cRIO
The cRIO uses a Linux based operating system. We will require SSH access for the compiler installations. To enable SSH access, go to the cRIO System Configuration portal (via Windows Internet Explorer to the cRIO IP address), and tick the "Enable Secure Shell Server (sshd)" check box. Restart the cRIO for this change to take place.

Access the cRIO via ssh as follows:
```bash
ssh admin@192.168.86.28
```
where the cRIO IP address can be obtained using NI MAX, and the password is as set via the cRIO browser interface. Once connected to the cRIO, check the installed OS
```bash
uname -a
```
which for the EGI cRIO returns as
```bash
Linux NI-cRIO-9038-01A42455 4.9.47-rt37-6.1.0f0 #1 SMP PREEMPT RT Sat Jun 9 13:19:07 CDT 2018 x86_64 GNU/Linux
```
and for the UMaine cRIO as
```bash
Linux NI-cRIO-9036-01B82934 4.9.47-rt37-6.1.0f0 #1 SMP PREEMPT RT Sat Jun 9 13:19:07 CDT 2018 x86_64 GNU/Linux
```
Both the EGI and the UMaine cRIO use Linux Kernel 4.9.47 (with LabVIEW 2018 install).

Before installation, check if the cRIO is connected to the internet
```bash
ping 8.8.8.8
```
which should return traffic. 

To install gcc, run the following sequence of commands one-by-one
```bash
opkg update
opkg install ldd
opkg install gcc gcc-symlinks
opkg install cpp cpp-symlinks
opkg install g++ g++-symlinks
opkg install libc6-utils
opkg install binutils
```
Each of those commands should result in a successful installation of the components listed. The first command is key, as this establishes the link to the NI package repository. The return from the opkg update command should look something like:
```bash
Downloading http://download.ni.com/ni-linux-rt/feeds/2018.5/x64/all/Packages.gz.
Updated source 'uri-all-0'.
Downloading http://download.ni.com/ni-linux-rt/feeds/2018.5/x64/core2-64/Packages.gz.
Updated source 'uri-core2-64-0'.
Downloading http://download.ni.com/ni-linux-rt/feeds/2018.5/x64/x64/Packages.gz.
Updated source 'uri-x64-0'.
```

## Create some code directories on the cRIO
The recommended directory structure can be created as follows:
```bash
cd
mkdir ipk
mkdir rosco
cd rosco/
mkdir c-interface-test
mkdir c-interface 
mkdir fortran 
```

## Testing gcc on the cRIO
At this stage, we can check if the gcc compile tools work as expected. Copy the file main_hello.c from the c-interface-test folder to the cRIO. Copying the file from the host PC to the cRIO can be done using scp, with an example given below:
```bash
scp main_hello.c admin@192.168.86.28:/home/admin/rosco/c-interface-test
```
To compile and run this file, navigate to the correct directory on the cRIO (/home/admin/rosco/c-interface-test in the above example) and
```bash
cd /home/admin/rosco/c-interface-test/
gcc main_hello.c -o cRIOHello
./cRIOHello
```
which should return
```bash
Hello World. The cRIO has a working C compiler now ...
```

## Installing gFortran on the cRIO
The NI cRIO package manager (as used for gcc install above) does unfortunately NOT include packages required for gFortran. EGI created these packages by creating a Docker container of the NI cRIO environment. All required packages, or ipk files, are located in the ipk-gfortran-2018 directory. Copy these files to the cRIO ipk folder
```bash
scp *.* admin@192.168.86.28:/home/admin/ipk
```
and install on the cRIO in the following order:
```bash
opkg install libquadmath0_6.3.0-r0_core2-64.ipk
opkg install libquadmath-dev_6.3.0-r0_core2-64.ipk
opkg install libgfortran3_6.3.0-r0_core2-64.ipk
opkg install libgfortran-dev_6.3.0-r0_core2-64.ipk
opkg install gfortran_6.3.0-r0_core2-64.ipk
opkg install gfortran-symlinks_6.3.0-r0_core2-64.ipk
```

## Compiling ROSCO on the cRIO
NOTE: At this stage, we do NOT yet know which ROSCO version to use. We currently use a version from the Master branch pull on 2020-11-03, after some fixes were made to the wind speed estimator. We need to converge onto a version with NREL - work ongoing by Nicole and Alan. The below documentation is written assuming we pull the version of the ROSCO github.

Download ROSCO from the NREL repo (https://github.com/nrel/rosco). We have found all of ROSCO to work on the cRIO, EXCEPT, the final call in DISCON.F90, which makes some Debug prints which do not work in LabVIEW. Comment out this line
```fortran
!    CALL Debug(LocalVar, CntrPar, DebugVar, avrSWAP, RootName, SIZE(avcOUTNAME))
```
Copy the ROSCO source code to the cRIO, and use the following directory structure:
```bash
build/ src/
```
where src contains the ROSCO source code files. Copy the compile-fortran.sh script from this repo into the build folder. To compile the ROSCO libary:
```bash
cd build
./compile-fortran.sh libROSCO
mv libROSCO.so /usr/local/lib/
```
To check if all the dependencies resolve correctly:
```bash
cd /usr/local/lib
ldd libROSCO.so
```
which should return something similar to this without any broken links
![libdiscon ldd](images/ldd-discon.png)

## Compiling the LabVIEW-ROSCO interface on the cRIO
LabVIEW does not support calls into Fortran directly. This can be resolved via a simple C->Fotran wrapper libary. LabVIEW then calls into the C wrapper, which calls into the ROSCO Fortran lib.

The LabVIEW->C->Fortran interface is coded in a single C file, callROSCO.c in the folder c-interface in this repo. Copy this file onto the cRIO,
```bash
scp callROSCO.c admin@192.168.86.28:/home/admin/rosco/c-interface
```
and compile as follows
```bash
 gcc -Wall -fmessage-length=0 -fPIC -shared -L/usr/local/lib -o libCallROSCO.so callROSCO.c -lROSCO
 mv libCallROSCO.so /usr/local/lib
```
Both libs, libROSCO.so and libCallROSCO.so, should now be in usr/local/lib. To check:
```bash
ls /usr/local/lib/
```
which should return
```bash
libCallROSCO.so* libROSCO.so*     libvisa.so@
```

## Current ROSCO issues
The FORTRAN ROSCO code has several issues at present that need to be resolved for LabVIEW interfacing.

### String message handling
For the gfortran compiler used on the cRIO, the TRIM function does not work as expected. Need to fix this line in DISCON.F90 from 
```fortran
avcMSG =  TRANSFER(TRIM(ErrMsg)//C_NULL_CHAR, avcMSG, SIZE(avcMSG))
```
to
```fortran
ErrMsg = ADJUSTL(TRIM(ErrMsg)) 
avcMSG =  TRANSFER(ErrMsg//C_NULL_CHAR,avcMsg,len(ErrMsg)+1)
```
### Integrator
Need to comment out the PI Controller in the PitchController routine. Unknown cause.

### Pitch Saturation
For PS_MODE=1, the saturation codes does not work in pitch controller. Causes seg fault. Unknow cause


## To use Sourcetree/Github desktop 

Labview provides a Merge and Diff tool which can be integrated with source control GUIs. To do this in Sourcetree, 

* Download LVMerge and LVDiff shell scripts
* Place them at C:\Program Files\Git\bin
* In Sourcetree > Tools > Options > Diff
* In External Diff Tool choose > Custom
* Diff Command: C:\Program Files\Git\bin_LVCompareWrapper.sh
* You can click on the file, Right Click > External Diff > Show Difference

## OLD Instructions for ECLIPSE - ignore from here

* libdiscon dependencies:


* In Eclipse, Under Properties -> C/C++ Build -> Settings -> Cross GCC Linker
	* Click on Libraries. Change the -L (library search path) to the location of the shared library.
	* Click on Miscellaneous. Update the name of the library to your .so, which is copied from cRIO and placed under the path above. (ex.  -ldiscon_20201009)
	* Build the Eclipse code and copy the <eclipse so name>.so file to /usr/local/lib on cRIO using Eclipse

To know more about how to cross compile C code (for cRIO) using Eclipse - http://www.ni.com/tutorial/52578/en/ .

* Finally, on cRIO, run the below command
	/sbin/ldconfig -v

* To confirm that all the dependencies are installed on cRIO, 

	* cd /usr/local/lib
	* ldd <eclipse so name>.so 
