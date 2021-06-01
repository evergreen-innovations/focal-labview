% script to convert from TDMS -> mat

clearvars; close all; clc;

addpath('functions/')

dataFile = '../97-data-labview/2021-04-19/wind_tests_2021_04_19_22_58_38';

[data,~,chanNames] = convertTDMS(false,[dataFile,'.tdms']);

save([dataFile,'.mat'],'data','chanNames')