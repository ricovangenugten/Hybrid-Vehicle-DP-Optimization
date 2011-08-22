% Script to process dpm results

% Start clean
clear all; close all; clc

% load file
% results_file = 'output/results_7.3e-06_15x1_o_c.mat'
% results_file = 'output/results_0.081_15x1_o_c.mat'
% results_file = 'output/results_0.18_15x3_o_c.mat'
% results_file = 'output/results_0.27_15x5_o_c.mat'
% results_file = 'output/results_0.37_15x7_o_c.mat'
% results_file = 'output/results_0.46_15x9_o_c.mat'
% results_file = 'output/results_0.56_15x11_o_c.mat'
% results_file = 'output/results_0.65_15x13_o_c.mat'
% results_file = 'output/results_0.75_15x14_o_c.mat'
% results_file = 'output/results_0.85_15x16_o_c.mat'

% results_file = 'output/results_7.3e-06_15x1_f_c.mat'
% results_file = 'output/results_0.081_15x1_f_c.mat'
% results_file = 'output/results_0.18_15x3_f_c.mat'
% results_file = 'output/results_0.27_15x5_f_c.mat'
% results_file = 'output/results_0.37_15x7_f_c.mat'
% results_file = 'output/results_0.46_15x9_f_c.mat'
% results_file = 'output/results_0.56_15x11_f_c.mat'
% results_file = 'output/results_0.65_15x13_f_c.mat'
% results_file = 'output/results_0.75_15x14_f_c.mat'
% results_file = 'output/results_0.85_15x16_f_c.mat'

% results_file = 'output/results_0.46_15x9_o_n.mat'
% results_file = 'output/results_0.46_15x9_f_n.mat'


load(results_file);

% load engine model
run FC_CI67;

time = [1:1878];
t = [1:1877];

% Figures

% Shifting
figure;
subplot(411);
plot(t, cycle.wheel_speed*3.6);
xlabel('time [s]');
ylabel('vehicle speed [km/h]');

subplot(412);
plot(t, cycle.crankshaft_speed/2/pi*60);
xlabel('time [s]');
ylabel('crankshaft speed [rpm]');

subplot(413);
plot(t, cycle.crankshaft_torque);
grid;
xlabel('t [s]'); 
ylabel('crankshaft torque [Nm]');

subplot(414);
plot(t, cycle.gearnumbers);
grid;
xlabel('t [s]'); 
ylabel('gear number');

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