% ADVISOR data file:  ESS_NIMH6.m     
%
% Data source:
%
% Insight file created from NREL lab test data  
% 		NREL test data from testing entire Insight Battery Pack Jan.2001 (Insight Model Year 2000)
%     
%		Insight pack is reported to be same technology as Japanese Prius (1998) with 20 modules instead of 40
%          Battery Type: NiMH Spiral Wound
%				Nominal Cell Voltage: 1.2V
%				Total Cells: 120 (6 cells x 20 modules)  (40 modules for Japanese Prius)
%				Nominal Voltage: 144 V (288 V for Japanese Prius)
%				Published Capacity: 6.5 Ah
%
%    Tests performed at 25 deg C following the PNGV Hybrid Pulse Power Characterization (HPPC) Procedure
%
% Data confirmation:
%		This data comes from Testing at NREL in the Battery Thermal Management Lab
%
% Notes:
%
%  
% Created on: 2/6/01
% By:  KJK, NREL 
%
% Revision history at end of file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FILE ID INFO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess_description='Spiral Wound NiMH Used in Insight & Japanese Prius';
ess_version=2002; % version of ADVISOR for which the file was generated
ess_proprietary=0; % 0=> non-proprietary, 1=> proprietary, do not distribute
ess_validation=0; % 0=> no validation, 1=> data agrees with source data, 
% 2=> data matches source data and data collection methods have been verified
disp(['Data loaded: ESS_NIMH6 - ',ess_description])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SOC RANGE over which data is defined
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess_soc=[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];  % (--)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Temperature range over which data is defined
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following data was obtained at 25 deg C.  Assume all values are the same for all temperatures
ess_tmp=[0 25];  % (C) place holder for now

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOSS AND EFFICIENCY parameters (from ESS_Prius_pack) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters vary by SOC horizontally, and temperature vertically
% the average of 5 discharge cycles at 6.5A at 25 deg C was 5.995Ah.
% Data (Ah): 6.030 5.973 5.990 5.989 5.995

ess_max_ah_cap=[
   6.0
   6.0
];	% (A*h), max. capacity at 6.5 A, indexed by ess_tmp

% average coulombic (a.k.a. amp-hour) efficiency below, indexed by ess_tmp
% Coulombic Efficiency - 6.5A discharge, 3A charge to dV/dt of 0.035V across the pack (120 cells)
% DATA: 90.991 90.308 90.470 90.386 90.327 
ess_coulombic_eff=[
   .905
   .905
];  % (--); 

% module's resistance to being discharged, indexed by ess_soc and ess_tmp
% The discharge resistance is the average of 4 tests from 10 to 90% soc at the following
%  discharge currents: 6.5, 6.5, 18.5 and 32 Amps
%  The 0 and 100 % soc points were extrapolated
ess_r_dis=[
	0.0377	0.0338	0.0300	0.0280	0.0275	0.0268	0.0269	0.0273	0.0283	0.0298	0.0312
	0.0377	0.0338	0.0300	0.0280	0.0275	0.0268	0.0269	0.0273	0.0283	0.0298	0.0312
   ]; 


% module's resistance to being charged, indexed by ess_soc and ess_tmp
% The discharge resistance is the average of 4 tests from 10 to 90% soc at the following
%  discharge currents: 5.2, 5.2, 15 and 26 Amps
%  The 0 and 100 % soc points were extrapolated
ess_r_chg=[
   0.0235	0.0220	0.0205	0.0198	0.0198	0.0196	0.0198	0.0197	0.0203	0.0204	0.0204
	0.0235	0.0220	0.0205	0.0198	0.0198	0.0196	0.0198	0.0197	0.0203	0.0204	0.0204
   ]; 
   
% module's open-circuit (a.k.a. no-load) voltage, indexed by ess_soc and ess_tmp
ess_voc=[
	7.2370	7.4047	7.5106	7.5873	7.6459	7.6909	7.7294	7.7666	7.8078	7.9143	8.3645
	7.2370	7.4047	7.5106	7.5873	7.6459	7.6909	7.7294	7.7666	7.8078	7.9143	8.3645
];  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LIMITS (from ESS_Prius_pack)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess_min_volts=6;% 1 volt per cell times 6 cells lowest from data was 255V so far 8/26/99
ess_max_volts=9; % 1.5 volts per cell times 6 cells highest from data so far was 361V 8/26/99

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OTHER DATA (from ESS_Prius_pack except where noted)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ess_module_mass=(44*.4536)/20;  % (kg), mass of Insight pack (44 lb Automotive News, July 12) divided by 20 modules								
ess_module_num=1;  %20 modules in INSIGHT pack, 40 modules in Prius Pack

ess_cap_scale=1; % scale factor for module max ah capacity

% user definable mass scaling relationship 
ess_mass_scale_fun=inline('(x(1)*ess_module_num+x(2))*(x(3)*ess_cap_scale+x(4))*(ess_module_mass)','x','ess_module_num','ess_cap_scale','ess_module_mass');
ess_mass_scale_coef=[1 0 1 0]; % coefficients in ess_mass_scale_fun

% user definable resistance scaling relationship
ess_res_scale_fun=inline('(x(1)*ess_module_num+x(2))/(x(3)*ess_cap_scale+x(4))','x','ess_module_num','ess_cap_scale');
ess_res_scale_coef=[1 0 1 0]; % coefficients in ess_res_scale_fun

%battery thermal model 
ess_th_calc=1;                             % --     0=no ess thermal calculations, 1=do calc's
ess_mod_cp=800;                            % 800 J/kgK  ave heat capacity of module from calorimeter test
ess_set_tmp=35;                            % C      thermostat temp of module when cooling fan comes on
%ess_area_scale=1.6*(ess_module_mass/11)^0.7;   % --     if module dimensions are unknown, assume rectang shape and scale vs PB25
ess_dia=0.0322;% m
ess_length=0.374; %m
ess_mod_sarea=pi*ess_dia*ess_length;       % m^2    total module surface area exposed to cooling air (typ rectang module)
ess_mod_airflow=0.01;                      % kg/s   cooling air mass flow rate across module (20 cfm=0.01 kg/s at 20 C)
ess_mod_flow_area=2*0.00317*ess_length;    % m^2    cross-sec flow area for cooling air per module (assumes 10-mm gap btwn mods)
ess_mod_case_thk=.1/1000;                   % m      thickness of module case (typ from Optima)
ess_mod_case_th_cond=0.20;                 % W/mK   thermal conductivity of module case material (typ polyprop plastic - Optima)
ess_air_vel=ess_mod_airflow/(1.16*ess_mod_flow_area); % m/s  ave velocity of cooling air
ess_air_htcoef=30*(ess_air_vel/5)^0.8;      % W/m^2K cooling air heat transfer coef.
ess_th_res_on=((1/ess_air_htcoef)+(ess_mod_case_thk/ess_mod_case_th_cond))/ess_mod_sarea; % K/W  tot thermal res key on
ess_th_res_off=((1/4)+(ess_mod_case_thk/ess_mod_case_th_cond))/ess_mod_sarea; % K/W  tot thermal res key off (cold soak)
% set bounds on flow rate and thermal resistance
ess_mod_airflow=max(ess_mod_airflow,0.001);
ess_th_res_on=min(ess_th_res_on,ess_th_res_off);
%clear ess_dia ess_length ess_mod_sarea ess_mod_flow_area ess_mod_case_thk ess_mod_case_th_cond ess_air_vel ess_air_htcoef ess_area_scale


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REVISION HISTORY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2/7/01 created this file from Insight Battery test data at NREL
% 7/30/01:tm added user defineable scaling functions for mass=f(ess_module_num,ess_cap_scale,ess_module_mass) 
%            and resistance=f(ess_module_num,ess_cap_scale)*base_resistance