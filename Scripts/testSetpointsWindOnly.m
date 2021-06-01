% create test setpoints for LabVIEW, using nearest lower value

clearvars; close all; clc;

% all numbers at full scale

time = [0:0.1:100, 500:0.1:600, 1000:0.1:1100, 2000];

numFans = 32;

fans = zeros(numFans,length(time));

fans(:,time>0) = repmat((time(time>0)-0)/200, numFans,1);
fans(:,time>100) = repmat(fans(1,time==100), numFans, sum(time>100));
fans(:,time>500) = repmat(fans(1,time==500) + (time(time>500)-500)/200, numFans, 1); 
fans(:,time>600) = repmat(fans(1,time==600), numFans, sum(time>600));
fans(:,time>1000) = repmat(fans(1,time==1000) - (time(time>1000)-1000)/100, numFans, 1); 
fans(:,time>1100) = repmat(fans(1,time==1100), numFans, sum(time>1100));

fans(5,:) = fans(5,:)*0.5; % just to have one a bit different for testing

setpoint = [time; fans];

figure
subplot(2,1,1)
plot(setpoint(1,:),setpoint(2,:))

subplot(2,1,2)
plot(setpoint(1,:),setpoint(2:33,:))

writematrix(setpoint','setpointsWindOnlyV0.txt','Delimiter','\t')