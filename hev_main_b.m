% Start clean
clear all; close all; clc
global scale_em scale_eng

load FTP_75
speed_vector = V_z;
acceleration_vector = [0;diff(V_z)];
gearnumber_vector = G_z;

Pmot = 20;
Peng = 100;

scale_eng = Peng/100;
scale_em = Pmot/25;

% create grid
grd.Nx{1}    = 187; 
grd.Xn{1}.hi = 0.7; 
grd.Xn{1}.lo = 0.4;

grd.Nu{1}    = 21; 
grd.Un{1}.hi = 1; 
grd.Un{1}.lo = -1;	% Att: Lower bound may vary with engine size.

% set initial state
grd.X0{1} = 0.5;

% final state constraints
grd.XN{1}.hi = 0.51;
grd.XN{1}.lo = 0.5;

% define problem
prb.W{1} = speed_vector; 
prb.W{2} = acceleration_vector; 
prb.W{3} = gearnumber_vector; 
prb.Ts = 1;
prb.N  = 1876*1/prb.Ts + 1;

% set options
options = dpm();
options.UseLine = 0;
options.SaveMap = 1;
options.Iter = 5;
options.InputType = 'd';
options.FixedGrid = 0;
[res dyn] = dpm(@hev_b,[],grd,prb,options);

% Outputs
SOC = res.X{1,1};
time = [0: 1877];

% Figures
% SOC
figure
plot(time,SOC)

% Fuel consumption
figure
plot(time(1:end-1),cumsum(res.m_dot_fuel))

% electric motor power vs drive power
figure
plot(time(1:end-1), res.Pb,'b')
hold on 
plot(time(1:end-1), res.Ttot.*res.wg,'r')

% plotting the Engine map
figure
title('Engine Map')
xlabel('\omega [rad/s]')
ylabel('Torque [Nm]')
hold on
we_list  = [112  168  224  280  336  392  447  503];
Tmax = [129  163  190  194  197  199  198  196];
plot(we_list,Tmax*scale_eng,'Color',[0 0 0],'LineWidth',2) 
%axis([100 510 0 210]);
hold on
plot(res.w_eng,res.Te,'o')

