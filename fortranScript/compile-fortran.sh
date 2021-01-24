#!/bin/bash
# Compile rosco code

if ["$1" == ""]; then
  echo "enter the so name"
fi
gfortran -g -Wall -ffree-form -fPIC -DIMPLICIT_DLLEXPORT -ffree-line-length-0 -c ../src/Constants.f90 
gfortran -g -Wall -ffree-form -fPIC -DIMPLICIT_DLLEXPORT -ffree-line-length-0 -c ../src/ROSCO_Types.f90 
gfortran -g -Wall -ffree-form -fPIC -DIMPLICIT_DLLEXPORT -ffree-line-length-0 -c ../src/Filters.f90 
gfortran -g -Wall -ffree-form -fPIC -DIMPLICIT_DLLEXPORT -ffree-line-length-0 -c ../src/Functions.f90
gfortran -g -Wall -ffree-form -fPIC -DIMPLICIT_DLLEXPORT -ffree-line-length-0 -c ../src/ControllerBlocks.f90 
gfortran -g -Wall -ffree-form -fPIC -DIMPLICIT_DLLEXPORT -ffree-line-length-0 -c ../src/ReadSetParameters.f90 
gfortran -g -Wall -ffree-form -fPIC -DIMPLICIT_DLLEXPORT -ffree-line-length-0 -c ../src/Controllers.f90 
gfortran -g -Wall -ffree-form -fPIC -DIMPLICIT_DLLEXPORT -ffree-line-length-0 -c ../src/DISCON.F90 


gfortran -shared Constants.o ControllerBlocks.o Controllers.o DISCON.o ROSCO_Types.o Filters.o Functions.o ReadSetParameters.o -o "$1".so
echo "Done-Check for .so"
