clearvars; close all; clc

%% === include local TDMS functions (v2.5 from Matlab fileshare) ==========
addpath('functions/')
addpath('functions/tdmsSubfunctions/')
% =========================================================================


%% === determine which fields to read =====================================
og = struct; 

%% === Read counter, only available for xsens 13
og.fullPathsKeep = {'/''Rotor Data''/''GeneratorSpeed(rad/s)''' '/''Rotor Data''/''TorqueSetpoint (Nm)''' '/''Rotor Data''/''Pitch Setpoint (rad)''' '/''Rotor Data''/''BufferLoopCounter''' '/''Rotor Data''/''MilliSec Time ''' '/''Rotor Data''/''AeroDynTq (Nm) ''' '/''Rotor Data''/''LoopCounter''' '/''Rotor Data''/''WS_simulation''' '/''Rotor Data''/''GenPower(W)''' }; 


% =========================================================================

%% === pick one of the experimental files  ================================
%filename='../tests-07-15-2020/rosco-tests_2020-16-07-02-32-09.tdms';        % Below Rated
% filename='../tests-07-15-2020/rosco-test-002_2020-16-07-02-38-59.tdms';    % SDMODE=0 Above Rated
% filename='../tests-07-15-2020/rosco-test-003_2020-16-07-02-48-36.tdms';    % SDMODE=1 Above Rated
%filename='../tests-08-04-2020/rosco-test-003_2020-04-08-23-37-16.tdms';      % New file Below Rated w/ Minimum Pitch Schedule (08-04-2020)  
%filename='../tests-08-04-2020/rosco-test-003_2020-04-08-23-49-21.tdms';      % New file Below Rated w/o Pitch Schedule (08-04-2020)  
filename='../tests-08-04-2020/rosco-test-003_2020-04-08-23-55-42.tdms';      % New file Above Rated (08-04-2020)  
 

% =========================================================================

%% === the target rate for the cRIO RT loop ===============================
dt = 0.001; % target file write rate (s)
% =========================================================================

%% === read the TDMS file ================================================
tic
data = TDMS_getStruct(filename,4,{'GET_DATA_OPTION','getsubset','OBJECTS_GET',og});
toc

% =========================================================================

%% === Load Data to Variables =============================================
genspeed = data.Rotor_Data.GeneratorSpeed_rad_s_.data;
%time = data.Rotor_Data.Counter.data;
%time_sec = data.Rotor_Data.Counter.data/1000;
timemscounter = data.Rotor_Data.MilliSec_Time_.data;
timeloopcounter = data.Rotor_Data.LoopCounter.data;
timebuffercounter = data.Rotor_Data.BufferLoopCounter.data;
tqsetpoint = data.Rotor_Data.TorqueSetpoint__Nm_.data;
pitchsetpoint = data.Rotor_Data.Pitch_Setpoint__rad_.data;
genpower = data.Rotor_Data.GenPower_W_.data;
aerodyntq = data.Rotor_Data.AeroDynTq__Nm__.data;
windspeed = data.Rotor_Data.WS_simulation.data;
genspeed = data.Rotor_Data.GeneratorSpeed_rad_s_.data;
time = timeloopcounter;
% =========================================================================

%% === plot the results ===================================================
figure ('Name','Labview-ROSCO Controller Plots')
subplot(5,1,1)
plot(time,windspeed,'r-')
xlabel('t (s)')
ylabel('WindSpeed (m/s)')
xlim([0 210])

subplot(5,1,2)
plot(time,genspeed,'-')
xlabel('t (s)')
ylabel('Gen Speed (rad/s)')
xlim([0 210])

subplot(5,1,3)
plot(time,tqsetpoint/1e6)
hold on
plot(time, aerodyntq/1e6);
xlabel('t (s)')
ylabel('Torque (MNm)')
legend('generator', 'aerodynamic')
xlim([0 210])
 %ylim([7 10])

 subplot(5,1,4)
 plot(time,pitchsetpoint*(180/pi))
 xlabel('t (s)')
 ylabel('Pitch (deg)')
xlim([0 210])

subplot(5,1,5)
plot(time,genpower/1e6)
xlabel('t (s)')
ylabel('Power (MW)')
xlim([0 210])
