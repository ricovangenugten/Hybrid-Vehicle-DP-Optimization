% Start clean
clear all; close all; clc

% Set globals
global scale_em scale_eng n_s n_p m_v

% load models
load FTP_75;run FC_CI67;
speed_vector = V_z;
acceleration_vector = [0;diff(V_z)];
gearnumber_vector = G_z;

%% Scaling

% Set motor powers
Pmot = 61;
Peng = 61;

% Calculate scale factors
scale_eng = Peng/67;
scale_em = Pmot/32;

% Set battery scaling
n_s      = 43;
n_p      = 4;

% Set vehicle mass
m_v      = 1729;


%% Setup DP

% create grid
% state is SOC
%grd.Nx{1}    = 187;   % Number of SOC grid points 
grd.Nx{1} = 50;
grd.Xn{1}.hi = 0.7;   % upper value for SOC
grd.Xn{1}.lo = 0.4;   % lower value for SOC

% input is electric motor utilization 
% (-1 = max neg. power, 1 = max pos. power
grd.Nu{1}    = 21;    % Number of input grid points
grd.Un{1}.hi = 1;     % upper value for input
grd.Un{1}.lo = -1;	  % lower value for input

% set initial SOC
grd.X0{1} = 0.5;

% final SOC constraints
grd.XN{1}.hi = 0.51;
grd.XN{1}.lo = 0.5;

% define problem vectors to be used in problem function
prb.W{1} = speed_vector; 
prb.W{2} = acceleration_vector; 
prb.W{3} = gearnumber_vector; 
prb.Ts = 1;
prb.N  = 1876*1/prb.Ts + 1;

% set options
options = dpm();
options.UseLine = 1;
options.SaveMap = 0;
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
title('state of charge')
xlabel('time [s]')
ylabel('SOC [-]')

% Fuel consumption
figure
plot(time(1:end-1),cumsum(res.m_dot_fuel))
title('vehicle fuel consumption')
xlabel('time [s]')
ylabel('fuel used [kg]')

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
ei = [0:5:230 230:10:260 260:20:300 300:50:400 400:100:1200];
we_list  = [78.54 104.72 130.90 157.08 183.26 209.44 235.62 261.80 287.98 314.16 340.34 366.52 392.70 418.88 445.06 471.24];
Tmax = [89.61 119.48 131.81 148.48 167.77 177.48 180.09 178.35 177.48 177.48 175.74 174 168.2 159.5 145 123.98];
plot(we_list,Tmax*scale_eng,'Color',[0 0 0],'LineWidth',2) 
%axis([75 475 0 210]);
hold on
plot(res.w_eng,res.Te,'o')
hold on
[c,h] = contour(fc_map_spd,fc_map_trq*scale_eng,fc_fuel_map_gpkWh',ei);
set(h,'ShowText','on','TextStep',get(h,'LevelStep')*2);
fill([0,fc_map_spd fc_map_spd(end)],[max(fc_max_trq*scale_eng)+100 fc_max_trq*scale_eng max(fc_max_trq*scale_eng)+100],'w');
axis ([min(fc_map_spd) max(fc_map_spd) 0 max(fc_max_trq)*scale_eng]);

