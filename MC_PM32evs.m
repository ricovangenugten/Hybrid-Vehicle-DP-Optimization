% ADVISOR Data file:  MC_PM32evs.m
%
% Data source:
% Biais F., Langry P. "Optimization of a permanent magnet traction motor 
% for electric vehicle", 
% Proceedings 15th Electric Vehicle Symposium, Brussels, October 1998.

% Data confidence level:  Good: data from a published paper

% Notes: Efficiency/loss data appropriate for a rated voltage system (voltage 
%        was not given in the source paper). The efficiency map appears from 
%        the paper to be 'calculated' rather than 'measured'. It results from 
% 			an optimization process of an existing water-cooled traction drive 
% 			provided with Nd-Fe-B magnets. 
%			The study has been carried out in collaboration with the French 
%			automaker RENAULT.

% Created on:  22-Feb-2000  
% 
% By:  Marco Santoro,  Dresden University of Technology (Germany), 
%		 marco@eti.et.tu-dresden.de
%
% Revision history at end of file.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FILE ID INFO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mc_description='Auxilec Thomson 32 kW (continuous), permanent magnet motor/controller';
mc_version=2002; % version of ADVISOR for which the file was generated
mc_proprietary=0; % 0=> non-proprietary, 1=> proprietary, do not distribute
mc_validation=0; % 0=> no validation, 1=> data agrees with source data, 
% 2=> data matches source data and data collection methods have been verified
disp(['Data loaded: MC_PM32evs - ',mc_description]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPEED & TORQUE RANGES over which data is defined
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (rad/s), speed range of the motor
mc_map_spd=[0 500 1000 1500 2000 2500 3000 3500 4000 4500 5000 5500 6000 6500 7000 7500 8000]*(2*pi/60);
% Conversion from rpm to rad/s 

% (N*m), torque range of the motor
mc_map_trq=[0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 210 220];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EFFICIENCY AND INPUT POWER MAPS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (--), efficiency map indexed vertically by mc_map_spd and 
% horizontally by mc_map_trq
mc_eff_map=0.01*[...
      70    75    78    77    73    72    70    68    66    65    60    59    58    55    52    50    49   48	47	46	45	44	43
      70    80    88    88.1  87    85.9  82    81    79    76    74    73    72    70    68    65    63   62	61	60	59	59.5	58	
      70    80    88.1  89    88.5  88.2  87.6  86.1  84.4  82.8  82    80.7  80    79    76    75    73   72.5   72    71    70.2  70    69
      70    80    88.1  90    90.1  90    89    88.2  87.9  86.8  86    85.3  84    82.7  82    81    80.2 80     79    78    76    75    74
      70    80    88    90    92    92    90    89.6  88.7  88.3  88    87.2  86.5  86    85    84    83   82     81    80.9  80.6  80.3  80.2
      70    80    88    89.5  90.2  92    91    90    89.5  89    88.7  88.2  87.7  87    86.5  86.1  85.9 84     83    82    82    81.9  81.8
      70    80    88    89.8  90.3  91    92    91    90.1  89.7  89    88.5  88.2  87.7  87.2  86.8  86.2 86     85.5  85.4  85    85    85     
      70    80    87.9  89.8  90.3  91    92    91    90.1  89.7  89.2  88.8  88.2  87.8  87.3  87    86.8 86.3   86    85.8  85    84    84
      70    80    86.5  89    90    91.2  92    90.2  89.7  89.6  89    88.7  88.5  88    87.7  87    87   86.8   86.2  86    85.8  85.6  85
      70    78    85    88    89    89.9  90.1  90    89.2  89    88.7  88.5  88    88    88    88    88   88	88	88	88	88	88	
      70    78    85    88    88.5  89    89.6  89.5  89.4  89    88.7  88.3  88.2  88    88    88    88   88	88	88	88	88	88		
      70    77    82    86.5  88.2  88.8  89    89    89    89    89    89    89    89    88    88    88   88	88	88	88	88	88  	
      70    76    82    86.1  88.1  88.5  88.8  89    89    89    89    89    89    89    89    88    88   88	88	88	88	88	88
      70		75		81		86		88		88.4	88.6	88.6	89		89		89		89		88		88		88		88	88   88	88	88	88	88	88
      70	   74		80.5	85.9	87.8	88.3	88.5	88.5	89		89		89		89		89		88		88		88	88   88	88	88	88	88	88
      70		73		80.2	85.8	87.6	88.2	88.4	89		89		89		89		89		89		89		88		88	88   88	88	88	88	88	88
   	70		72.5	80		85.7	87		88.1	88.2	88.2	89		89		89		89		89		89		88		88	88   88	88	88	88	88	88];
   
	%% find indices of well-defined efficiencies (where speed and torque > 0)
	pos_trqs=find(mc_map_trq>0);
	pos_spds=find(mc_map_spd>0);

	%% compute losses in well-defined efficiency area
	[T1,w1]=meshgrid(mc_map_trq(pos_trqs),mc_map_spd(pos_spds));
	mc_outpwr1_map=T1.*w1;
	mc_losspwr_map=(1./mc_eff_map(pos_spds,pos_trqs)-1).*mc_outpwr1_map; % for torque and speed > 0

	%% to compute losses in entire operating range
	%% ASSUME that losses are symmetric about zero-torque axis, and
     %% ASSUME that losses at zero torque are the same as those at the lowest
     %% positive torque, and
     %% ASSUME that losses at zero speed are the same as those at the lowest
     %% positive speed
	mc_losspwr_map=[fliplr(mc_losspwr_map) mc_losspwr_map(:,1) mc_losspwr_map];
	mc_losspwr_map=[mc_losspwr_map(1,:);mc_losspwr_map];

	%% compute input power (power req'd at electrical side of motor/inverter set)
	[T,w]=meshgrid(mc_map_trq,mc_map_spd);
	mc_outpwr_map=T.*w;   % for torque and speed >=0
   [T2,w2]=meshgrid(mc_map_trq(pos_trqs),mc_map_spd);
   temp=T2.*w2;   %  torque>0 and speed >=0
   mc_outpwr_map=[-fliplr(temp) mc_outpwr_map];
   mc_inpwr_map=mc_outpwr_map+mc_losspwr_map;  % (W)
   mc_map_trq=[-fliplr(mc_map_trq(pos_trqs)) mc_map_trq]; % negative torques are represented too
   mc_eff_map = mc_outpwr_map./mc_inpwr_map;
   mc_eff_map(mc_eff_map>1) = 1./mc_eff_map(mc_eff_map>1);
   %mc_eff_map=[fliplr(mc_eff_map(:,pos_trqs)) mc_eff_map]; % the new efficiency map 
   % considers regenerative torques too
   
%end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LIMITS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% max continuous torque curve of the motor indexed by mc_map_spd
mc_max_trq=0.7111*[200 202 209 209 206 170 130 118 100 90 80 71 68 61 53 52 50]; % (N*m)
mc_max_gen_trq=-1*0.7111*[200 202 209 209 206 170 130 118 100 90 80 71 68 61 53 52 50]; % (N*m), estimate

% maximum overtorque (beyond continuous, intermittent operation only)
% below is quoted (peak intermittent stall)/(peak continuous stall)
mc_overtrq_factor=45/32; 

mc_max_crrnt=300; % (A), maximum current allowed by the controller and motor, estimated
mc_min_volts=100; % (V), minimum voltage allowed by the controller and motor, estimated


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFAULT SCALING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (--), used to scale mc_map_spd to simulate a faster or slower running motor 
mc_spd_scale=1.0;

% (--), used to scale mc_map_trq to simulate a higher or lower torque motor
mc_trq_scale=1.0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OTHER DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mc_inertia=0.02;  % (kg*m^2), rotor's rotational inertia, estimated
mc_mass=48;  % (kg), mass of motor (35 kg) and controller (13 kg), calculated																			

% motor/controller thermal model
mc_th_calc=1;      % --     0=no mc thermal calculations, 1=do calcs
mc_cp=430;         % J/kgK  ave heat capacity of motor/controller (estimate: ave of SS & Cu)
mc_tstat=45;       % C      thermostat temp of motor/controler when cooling pump comes on
mc_area_scale=(mc_mass/91)^0.7;  % --     if motor dimensions are unknown, assume rectang shape and scale vs AC75
mc_sarea=0.4*mc_area_scale;      % m^2    total module surface area exposed to cooling fluid (typ rectang module)

%the following variable is not used directly in modelling and should always be equal to one
%it's used for initialization purposes
mc_eff_scale=1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CLEAN UP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear T w mc_outpwr1_map mc_losspwr_map T1 w1 pos_spds pos_trqs temp T2 w2


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REVISION HISTORY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 23-Feb-2000 (MS):  updated mc_max_crrnt 
% % 11/1/00:tm added max gen trq placeholder data
%

% Begin added by ADVISOR 3.2 converter: 30-Jul-2001
mc_mass_scale_coef=[1 0 1 0];

mc_mass_scale_fun=inline('(x(1)*mc_trq_scale+x(2))*(x(3)*mc_spd_scale+x(4))*mc_mass','x','mc_spd_scale','mc_trq_scale','mc_mass');

% End added by ADVISOR 3.2 converter: 30-Jul-2001