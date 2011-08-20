

function [X C I out] = hev_b(inp,par)

%HEV Computes the resulting state-of-charge based on current state-
%   of-charge, inputs and drive cycle demand.
%   
%   [X C I out] = HEV(INP,PAR)
%
%   INP   = input structure
%   PAR   = user defined parameters
%
%   X     = resulting state-of-charge
%   C     = cost matrix
%   I     = infeasible matrix
%   out   = user defined output signals

%define inputs
wg = inp.W{1};
Tg = inp.W{2};

% TORQUE SPLIT
%   engine inertia = 0.1 m
%   motor inertia  = 0.03 m
%   idle speed     = 100 rad/s

fc_map_spd=[750:250:4500]*pi/30;
fc_map_trq=[14.5 29 43.5 58 72.5 87 101.5 116 130.5 145 159.5 174 179.8];
fc_max_trq=[6.18 8.24 9.09 10.24 11.57 12.24 12.42 12.3 12.24 12.24 12.12 12 11.6 11 10 8.55]*14.5;

Te0_list = [20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20];
% Engine drag torque (Nm), when outside engine speed range limit
Te0  = interp1(fc_map_spd,Te0_list,min(max(wg,fc_map_spd(1)),fc_map_spd(end)));
% Total required torque (Nm)
Ttot = Te0.*(inp.U{1}~=1) + Tg;
% Torque provided by engine
Te  = (wg>0) .* (Ttot>0)  .* (1-inp.U{1}).*Ttot;
Tb  = (wg>0) .* (Ttot<=0) .* (1-inp.U{1}).*Ttot;
% Torque provided by electric motor
Tm  = (wg>0) .*    inp.U{1} .*       Ttot;

% ENGINE
% diesel lower heating value = 42426000 J/kg

fc_fuel_map_gpkWh=[726	468	309	280	259	259	251	250	250	255	267	268	267
613	370	289	265	249	241	236	235	235	237	239	240	240
545	311	277	256	243	230	227	226	226	226	222	223	224
500	305	279	253	241	230	225	222	219	218	218	217	215
500	329	280	254	243	233	226	220	216	213	210	209	208
495	331	286	259	245	234	227	221	215	210	207	204	203
500	336	291	261	248	236	228	222	215	209	207	206	206
500	339	297	264	248	238	230	224	218	215	209	208	208
494	350	302	267	249	240	233	226	219	217	213	211	211
534	369	314	273	250	243	237	230	226	221	217	217	217
628	400	324	280	261	248	241	234	228	224	222	222	222
832	460	336	293	270	250	245	237	230	227	227	227	227
830	470	350	305	275	259	249	242	237	233	230	228	228
905	500	365	317	280	266	254	247	242	238	234	234	234
788	500	404	329	297	272	260	250	247	242	239	238	238
1205	635	445	350	314	280	267	257	249	246	240	238	238];

w_eng = wg;
w_eng(w_eng<=100) = 100;
w_eng(w_eng>=471) = 471;

T_eng = Te;
T_eng(T_eng<=15.*par.scale_eng) = 15*par.scale_eng;
% fuel consumption map in g/s
[T,w]=meshgrid(fc_map_trq*par.scale_eng,fc_map_spd);
fc_map_kW=T.*w/1000;
fc_fuel_map=fc_fuel_map_gpkWh.*fc_map_kW/3600;
% maximum engine 
Tmax = fc_max_trq*par.scale_eng;
% fuel consumption per s
e_gs = interp2(fc_map_trq*par.scale_eng,fc_map_spd,fc_fuel_map,Te,w_eng.*ones(size(Te)));
e_gs(isnan(e_gs)) = 0;
% Fuel mass flow (function of power and efficiency)
m_dot_fuel = e_gs./1000;
% Maximum engine torque
Te_max = interp1(fc_map_spd,Tmax,w_eng,'linear*','extrap');
% Fuel power consumption
Pe = m_dot_fuel .* 42426000;
% Calculate infeasible
ine = (Te > Te_max);

% MOTOR (from ADVISOR PM32)
% motor speed list
red     = 0.5625;
wm_list = [0 500 1000 1500 2000 2500 3000 3500 4000 4500 5000 5500 6000 6500 7000 7500 8000]*(2*pi/60);
% motor torque list
Tm_list = [0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 210 220]*par.scale_em;
% motor maximum torque (indexed by speed list)
Tmmax   = 0.7111*[200 202 209 209 206 170 130 118 100 90 80 71 68 61 53 52 50]*par.scale_em;
% motor minimum torque (indexed by speed list)
Tmmin   = -1*0.7111*[200 202 209 209 206 170 130 118 100 90 80 71 68 61 53 52 50]*par.scale_em;
% motor efficiency map (indexed by speed list and torque list)
etam    = 0.01*[...
      70    75    78    77    73    72    70    68    66    65    60    59    58    55    52    50    49   48	47	 46	  45	44	  43
      70    80    88    88.1  87    85.9  82    81    79    76    74    73    72    70    68    65    63   62	61	 60	  59	59.5  58	
      70    80    88.1  89    88.5  88.2  87.6  86.1  84.4  82.8  82    80.7  80    79    76    75    73   72.5 72   71   70.2  70    69
      70    80    88.1  90    90.1  90    89    88.2  87.9  86.8  86    85.3  84    82.7  82    81    80.2 80   79   78   76    75    74
      70    80    88    90    92    92    90    89.6  88.7  88.3  88    87.2  86.5  86    85    84    83   82   81   80.9 80.6  80.3  80.2
      70    80    88    89.5  90.2  92    91    90    89.5  89    88.7  88.2  87.7  87    86.5  86.1  85.9 84   83   82   82    81.9  81.8
      70    80    88    89.8  90.3  91    92    91    90.1  89.7  89    88.5  88.2  87.7  87.2  86.8  86.2 86   85.5 85.4 85    85    85     
      70    80    87.9  89.8  90.3  91    92    91    90.1  89.7  89.2  88.8  88.2  87.8  87.3  87    86.8 86.3 86   85.8 85    84    84
      70    80    86.5  89    90    91.2  92    90.2  89.7  89.6  89    88.7  88.5  88    87.7  87    87   86.8 86.2 86   85.8  85.6  85
      70    78    85    88    89    89.9  90.1  90    89.2  89    88.7  88.5  88    88    88    88    88   88	88	 88	  88	88	  88	
      70    78    85    88    88.5  89    89.6  89.5  89.4  89    88.7  88.3  88.2  88    88    88    88   88	88	 88	  88	88	  88		
      70    77    82    86.5  88.2  88.8  89    89    89    89    89    89    89    89    88    88    88   88	88	 88	  88	88	  88  	
      70    76    82    86.1  88.1  88.5  88.8  89    89    89    89    89    89    89    89    88    88   88	88	 88	  88	88	  88
      70	75	  81	86	  88	88.4  88.6	88.6  89	89	  89	89	  88	88	  88	88	  88   88	88	 88	  88	88	  88
      70	74	  80.5  85.9  87.8	88.3  88.5	88.5  89	89	  89	89	  89	88	  88	88	  88   88	88	 88	  88	88	  88
      70	73	  80.2  85.8  87.6	88.2  88.4	89	  89	89	  89	89	  89	89	  88	88	  88   88	88	 88	  88	88	  88
   	  70	72.5  80    85.7  87	88.1  88.2	88.2  89	89	  89	89	  89	89	  88	88	  88   88	88	 88	  88	88	  88];
% Electric motor efficiency
e = (wg~=0) .* interp2(Tm_list,wm_list,etam,abs(Tm),wg.*ones(size(Tm))) + (wg==0);
% Summarize infeasible
inm = (isnan(e)) + (Tm<0)  .* (Tm < interp1(wm_list,Tmmin,wg,'linear*','extrap')) +...
                   (Tm>=0) .* (Tm > interp1(wm_list,Tmmax,wg,'linear*','extrap'));
e(isnan(e)) = 1;
% Calculate electric power consumption
Pm =  (Tm<0) .* wg.*Tm.*e + (Tm>=0) .* wg.*Tm./e;

% BATTERY
% state-of-charge list
soc_list = 0:0.1:1;
% discharging resistance (indexed by state-of-charge list)
R_dis    = [0.0377	0.0338	0.0300	0.0280	0.0275	0.0268	0.0269	0.0273	0.0283	0.0298	0.0312]*par.n_s/par.n_p; % ohm
% charging resistance (indexed by state-of-charge list)
R_chg    = [0.0235	0.0220	0.0205	0.0198	0.0198	0.0196	0.0198	0.0197	0.0203	0.0204	0.0204]*par.n_s/par.n_p; % ohm
% open circuit voltage (indexed by state-of-charge list)
V_oc     = [7.2370	7.4047	7.5106	7.5873	7.6459	7.6909	7.7294	7.7666	7.8078	7.9143	8.3645]*par.n_s; % volt

% Battery efficiency
% Battery internal resistance
r = (Pm>0)  .* interp1(soc_list, R_dis, inp.X{1},'linear*','extrap')...
  + (Pm<=0) .* interp1(soc_list, R_chg, inp.X{1},'linear*','extrap');

% Battery current limitations
%   battery capacity            = 6*par.n_p Ah 
%   maximum discharging current = 63*par.n_p A
%   maximum charging current    = 60*par.n_p A
im = (Pm>0) .* 63*par.n_p + (Pm<=0) .* 60*par.n_p;
% Battery voltage
v = interp1(soc_list, V_oc, inp.X{1},'linear*','extrap');
% Battery current, max 60% recovery
Ib  = ((Ttot<=0).*0.6 + (Ttot>0)) .* (v-sqrt(v.^2 - 4.*r.*Pm))./(2.*r);
% New battery state of charge
X{1}  = - Ib / (6*par.n_p* 3600) + inp.X{1};
% Battery power consumption
Pb =   Ib .* v;
% Update infeasible 
inb = (v.^2 < 4.*r.*Pm);
% Set new state of charge to real values
X{1} = (conj(X{1})+X{1})/2;
Pb   = (conj(Pb)+Pb)/2;
Ib   = (conj(Ib)+Ib)/2;

% COST
% Summarize infeasible matrix
I = (inb+ine+inm~=0);
% Calculate cost matrix (fuel mass flow)
C{1}  = (Pe / 42426000);

% SIGNALS
%   store relevant signals in out
out.Te = Te;
out.Tm = Tm;
out.Tb = Tb;
out.wg = wg;
out.Ib = Ib;
out.Pb = Pb;
out.Tema = Te_max;
out.m_dot_fuel = m_dot_fuel;
out.Ttot = Ttot;
out.w_eng = w_eng;

% REVISION HISTORY
% =========================================================================
% DATE      WHO                 WHAT
% -------------------------------------------------------------------------
% 





