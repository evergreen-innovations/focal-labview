% test script for FOCAL data

clearvars; close all; clc;
set(0,'DefaultFigureWindowStyle','docked')
addpath('functions/')

dataFile = '../97-data-labview/2021-04-19/wind_tests_2021_04_19_22_58_38';

load(dataFile)

printFocalChannels(data);

dataGroupName = 'focalWind';
constGroupName = 'Constants';

rad2Deg = 180/pi;
radps2RPM = 60/(2*pi);

fs = 200;
smoothWidth = 5;
smoothType = 2;
smoothEnd = 1;


time                = parseFocalData(data,dataGroupName,'dataTime_s');
dataLoopCounter     = parseFocalData(data,dataGroupName,'dataLoopCounter');
towerBaseMx_Nm      = parseFocalData(data,dataGroupName,'towerBaseMx_Nm')*rad2Deg;
towerBaseMy_Nm      = parseFocalData(data,dataGroupName,'towerBaseMy_Nm')*rad2Deg;
accX_m_s2           = parseFocalData(data,dataGroupName,'accX_m_s2')*radps2RPM;
accY_m_s2           = parseFocalData(data,dataGroupName,'accY_m_s2');
accZ_m_s2           = parseFocalData(data,dataGroupName,'accZ_m_s2')*radps2RPM;
traverseX_m         = parseFocalData(data,dataGroupName,'traverseX_m');
traverseY_m         = parseFocalData(data,dataGroupName,'traverseY_m');
traverseZ_m         = parseFocalData(data,dataGroupName,'traverseZ_m');

fprintf('Time statistics. dt mean = %5.4f; dt max = %5.4f; dt min = %5.4f\n',mean(diff(time)),max(diff(time)),min(diff(time)))

dtOkay = min(diff(dataLoopCounter) == 1) == 1;
if dtOkay
    fprintf('Test passed. All data frames sequential.')
else
    warning('Some data frames not sequential. Check dataLoopCounter. Missed %u of %u frames.\n', sum(diff(dataLoopCounter)~=1)', length(dataLoopCounter))
end

%% === Some plotting ======================================================


figure
hist(diff(time));
%set(gca,'yscale','log')


figure('Name','Time check')
plot(time,dataLoopCounter)
xlabel('time (s)')
ylabel('Ctrl loop counter')


figure('Name','towerBase')
plot(time,towerBaseMx_Nm)
hold on
plot(time,towerBaseMy_Nm)
xlabel('time (s)')
ylabel('Torque (Nm)')
legend('TowerBase Mx','TowerBase My')
grid on




