% Script to process dpm results

% Start clean
clear all; close all; clc

% load file
results_file = 'output/results_0.84.mat'
load(results_file);

% load engine model
run FC_CI67;

% Figures

% SOC
figure
plot(time,res.X{1,1})
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
plot(time(1:end-1), res.Te.*res.wg,'r')
legend('motor', 'engine')

% plotting the Engine map
figure
title('Engine Map')
xlabel('\omega [rad/s]')
ylabel('Torque [Nm]')
hold on

ei = [0:5:230 230:10:260 260:20:300 300:50:400 400:100:1200];
plot(fc_map_spd,fc_max_trq*par.scale_eng,'Color',[0 0 0],'LineWidth',2) 
hold on
plot(res.w_eng,res.Te,'o')
[c,h] = contour(fc_map_spd,fc_map_trq*par.scale_eng,fc_fuel_map_gpkWh',ei);
set(h,'ShowText','on','TextStep',get(h,'LevelStep')*2);
fill([0,fc_map_spd fc_map_spd(end)],[max(fc_max_trq*par.scale_eng)+100 fc_max_trq*par.scale_eng max(fc_max_trq*par.scale_eng)+100],'w');
axis ([min(fc_map_spd) max(fc_map_spd) 0 max(fc_max_trq)*par.scale_eng]);

% fuel used
fuel_usage = sum(res.m_dot_fuel)