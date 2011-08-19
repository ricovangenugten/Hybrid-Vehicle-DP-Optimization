% Start clean
clear all; close all; clc

% load drive cycle
load FTP_75;
speed_vector = V_z;
acceleration_vector = [0;diff(V_z)];
gearnumber_vector = G_z;

% load engine model
run FC_CI67;

% load motor model
run MC_PM32evs

% load battery model
run ESS_NIMH6

%% Fixed parameters

par.Eta_gb = 0.95; %[-]
par.R_w    = 0.28; %[m]
par.c_r    = 1.5/100;  %[%]
par.c_d    = 0.3;  %[-]
par.Af     = 2;    %[m^2]
par.rho    = 1.2;  %[kg/m^3]
par.g      = 9.81; %[m/s^2]

par.t_slip = 0.2;  % slip time when shifting [s]

par.r_em = 1.4925; % reduction gear electric motor

%% Scaling

vehicles.Pmot = [106];
vehicles.Peng = [20];
vehicles.n_s =  [30];
vehicles.n_p =  [6];

%% Setup DP

% create grid
% state is SOC
grd.Nx{1}    = 187;   % Number of SOC grid points 
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

for i=[1:length(vehicles.Pmot)]
  
  par.hf = vehicles.Pmot(i)/(vehicles.Pmot(i)+vehicles.Peng(i));

  % Calculate scale factors
  par.scale_eng = vehicles.Peng(i)/67;
  par.scale_em  = vehicles.Pmot(i)/32;

  % Set battery scaling
  par.n_s = vehicles.n_s(i);
  par.n_p = vehicles.n_p(i);

  % Vehicle mass
  m_0   = 1300; %[kg]
  m_ice = (fc_base_mass+fc_acc_mass)*par.scale_eng; %[kg]
  m_em  = mc_mass*par.scale_em;
  m_bat = ess_module_mass*par.n_s*par.n_p; %[kg]

  par.m_v = m_0 + m_ice + m_em + m_bat; %[kg]

  par
        
  % run DP function
  [res dyn] = dpm(@hev_b,par,grd,prb,options);

  % Define time vector
  time = [0: prb.N];

  % Save results
  mkdir('output');
  save(strcat('output/results_', num2str(par.hf,2), '.mat'), 'res', 'par', 'time');

end