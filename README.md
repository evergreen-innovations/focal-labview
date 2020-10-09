# FOCAL RT Labview Control Code

## To use Sourcetree/Github desktop 

Labview provides a Merge and Diff tool which can be integrated with source control GUIs. To do this in Sourcetree, 

* Download LVMerge and LVDiff shell scripts
* Place them at C:\Program Files\Git\bin
* In Sourcetree > Tools > Options > Diff
* In External Diff Tool choose > Custom
* Diff Command: C:\Program Files\Git\bin_LVCompareWrapper.sh
* You can click on the file, Right Click > External Diff > Show Difference

## To Compile ROSCO code on cRIO

* Needs gfortran installed on cRIO

* Download the shell script from fortranScript/compile-fortran onto the cRIO
* Download the rosco source code from (https://github.com/nrel/rosco) and make changes as needed.

	* mkdir build
	* cd build
	* ./compile-fortran.sh libdiscon20200910 <name you want to give the shared lib>
	* cp <so name> /usr/local/lib/.
	* copy the shared library using SCP tool onto the local computer. I use WinSCP.

* We have written a wrapper code in C, which calls the fortran shared library and acts as a bridge between Labview and ROSCO-Fortran.

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
