% Start clean
clear all; close all; clc

% load drive cycle
load FTP_75;
speed_vector = V_z;
acceleration_vector = [0;diff(V_z)];
gearnumber_vector_ftp = G_z;

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

%% Vehicles definition
%                     [smallest ice                    baseline]   
vehicles.Peng =       [  20  33  46  59  72	85  98 111 124	137  72  72   ];
vehicles.Pmot =       [ 111  98  87  74  62	49  37	24	11 1e-3  62  62   ];
vehicles.n_s =        [  15  15  15  15  15  15  15  15  15   15  15  15  ];
vehicles.n_p =        [  16  14  13  11	 9   7	 5	 3	 1	  1   9   9   ];
vehicles.shift =      [  'o' 'o' 'o' 'o' 'o' 'o' 'o' 'o' 'o'  'o' 'o' 'f' ];
vehicles.clutchloss = [  'c' 'c' 'c' 'c' 'c' 'c' 'c' 'c' 'c'  'c' 'n' 'c' ];

%vehicles.Peng =       [ 20 ];
%vehicles.Pmot =       [111 ];
%vehicles.n_s =        [ 15 ];
%vehicles.n_p =        [ 16 ];
%vehicles.shift =      [ 'o'];
%vehicles.clutchloss = [ 'c'];


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

% set options
options = dpm();
options.UseLine = 1;
options.SaveMap = 0;
options.Iter = 5;
options.InputType = 'd';
options.FixedGrid = 0;

for k=[1:length(vehicles.Pmot)]
  
  par.hf = vehicles.Pmot(k)/(vehicles.Pmot(k)+vehicles.Peng(k));
  
  par.shift = vehicles.shift(k);
  par.clutchloss = vehicles.clutchloss(k);

  % Calculate scale factors
  par.scale_eng = vehicles.Peng(k)/67;
  par.scale_em  = vehicles.Pmot(k)/32;

  % Set battery scaling
  par.n_s = vehicles.n_s(k);
  par.n_p = vehicles.n_p(k);

  % Vehicle mass
  m_0   = 1300; %[kg]
  m_ice = (fc_base_mass+fc_acc_mass)*par.scale_eng; %[kg]
  m_em  = mc_mass*par.scale_em;
  m_bat = ess_module_mass*par.n_s*par.n_p; %[kg]

  par.m_v = m_0 + m_ice + m_em + m_bat; %[kg]
  
  % Wheel speed (rad/s)
  wv  = speed_vector ./ 0.28;
  % Wheel torque (Nm) friction + air + 
  Tv = (par.m_v*par.c_r*par.g + 0.5*par.rho*par.Af*par.c_d.*speed_vector.^2 + par.m_v.*acceleration_vector) .* par.R_w;

  g_w = zeros(length(wv), 1); % gear number 
  g_w(1) = 1; % initial gear
  
  gears = [0.0564 0.1551 0.2538 0.3525 0.4512 0.5499];
  odd_gears = [1 3 5];
  even_gears = [2 4 6];
  
  %shifting limit for negative torque
  w_tr_limit = 2500/60*2*pi; 

  w_tr_threshold = 1000/60*2*pi;
  T_shifting_min = 17; % don't shift when requested torque is lower than this limit

  if par.shift == 'o'
    % determine gear every time step
    for i = [2:length(wv)]

      if mod(g_w(i-1), 2) 
        % current gear is odd, current gear and even gears available
        gears_av = [g_w(i-1) even_gears];
      else
        % current gear is even, current gear and odd gears available
        gears_av = [g_w(i-1) odd_gears];
      end

      if Tv(i) < 0

        % negative torque, remmennn

        % loop through available gears, select gear that does not exceed rev threshold
        for j = [1:length(gears_av)]
          if wv(i) < gears(gears_av(j))*w_tr_limit
            g_w(i) = gears_av(j);
            break;
          end
        end

      elseif (wv(i)/gears(1) < w_tr_threshold)

        % very low or zero engine speed in first gear, vehicle launch

        if (g_w(i-1) == 3 || g_w(i-1) == 5)
          % previous gear is 3 or 5, shift to 2
          g_w(i) = 2;
        else
          % previous gear is even or 1, shift to 1
          g_w(i) = 1;
        end

      elseif (Tv(i)*gears(1) < T_shifting_min)

        % very low engine torque needed, even in first gear, so don't shift

        g_w(i) = g_w(i-1);

      else

        % positive torque, vroem!

        % reset min fuel consumption
        fc_min_i = 0;

        % loop through available gears
        for j = [1:length(gears_av)]
          % engine speed and torque at this gear
          w_tr_j = wv(i)/gears(gears_av(j));
          T_tr_j = Tv(i)*gears(gears_av(j));

          if (T_tr_j < interp1(fc_map_spd, fc_max_trq, w_tr_j));
            % below max torque of unscaled fuel map

            %fuel consumption at this gear using unscaled fuel map
            fc_j = interp2(fc_map_spd, fc_map_trq, fc_fuel_map_gpkWh', w_tr_j, T_tr_j);

            % lowest bfsc at this gear? then save gear
            if (fc_min_i == 0 || fc_j < fc_min_i) && isfinite(fc_j)
              fc_min_i = fc_j;
              g_w(i) = gears_av(j);
            end
          end
        end
      end
    end

    gearnumber_vector = g_w;
  else
    gearnumber_vector = gearnumber_vector_ftp;
  end
  
  par.n_shift = 0; % shift count
  
  for i=[2:length(Tv)]  
    if (gearnumber_vector(i) ~= gearnumber_vector(i-1))
      % gear changed, count
      par.n_shift = par.n_shift + 1;

      % clutch loss
      if par.clutchloss == 'c' && gearnumber_vector(i-1) ~= 0 && gearnumber_vector(i) ~= 0
        Tc = abs((gears(gearnumber_vector(i-1))^2 - gears(gearnumber_vector(i))^2)*Tv(i))*par.t_slip / ...
          (6*gears(gearnumber_vector(i-1))*gears(gearnumber_vector(i)))
        
        Tv(i) = Tv(i) + Tc;  
      end
    end
  end
  
  % Crankshaft speed (rad/s)
  crankshaft_speed_vector  = (gearnumber_vector>0) .* 1./gears(gearnumber_vector + (gearnumber_vector==0))' .* wv;
  % Crankshaft torque (Nm)
  crankshaft_torque_vector  = (gearnumber_vector>0) .* (Tv>0)  .* Tv .* gears(gearnumber_vector + (gearnumber_vector==0))' ./ 0.95...
   + (gearnumber_vector>0) .* (Tv<=0) .* Tv .* gears(gearnumber_vector + (gearnumber_vector==0))' .* 0.95;
 
  %output paramaters
  par
  
  % define problem vectors to be used in problem function
  prb.W{1} = crankshaft_speed_vector;   
  prb.W{2} = crankshaft_torque_vector;
  prb.Ts = 1;
  prb.N  = length(wv);

  % run DP function
  [res dyn] = dpm(@hev_b,par,grd,prb,options);
  
  cycle.wheel_speed = speed_vector;
  cycle.gearnumbers = gearnumber_vector;
  cycle.crankshaft_speed = crankshaft_speed_vector;
  cycle.crankshaft_torque = crankshaft_torque_vector;
  
  % Save results
  mkdir('output');
  save(strcat('output/results_', num2str(par.hf,2), '_', num2str(par.n_s), 'x', num2str(par.n_p), '_', par.shift, '_', par.clutchloss, '.mat'), 'res', 'par', 'cycle');

end