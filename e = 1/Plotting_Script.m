%% Ciaran O'Brien - 6714221
%  Low-Thrust Trajectory Design for Satellite Mega-Constellation Deployment
%  Energy Optimal Transfer Plotter
clear;
clc;
clf;
close all;
format longG;

%% Inputs
[inp,pars] = Constants;

r2d = 180/pi;

%% X Values from PSO
Lambda = [0.052951601484711,-0.433729510633226,-0.074297601939783,-0.010802687297949,-0.286576792311210,0.487455447725607,0.013437745295469,0.695354847104579]';

%% Trajectory Plotter
[X,Trajectory] = F_Solve_Plot(Lambda,pars);


%% Pulling Values
LU = pars.Unit.LU;
TU = pars.Unit.TU;
MU = pars.Unit.MU;
VU = pars.Unit.VU;

X_R = X(:,1:7)';
X_Report = X_R.*[LU;LU;LU;VU;VU;VU;MU];

t = inp.Orbits.ToF_E/3600;
t_orbit = linspace(0,t,length(X));

SF = Trajectory.SF;
u = Trajectory.u;
H = Trajectory.H;
COE = Trajectory.COE';
Re = inp.Earth.Re;
NormX = pars.Unit.NormX;

a_t = COE(1,:)*LU; e_t = COE(2,:); i_t = COE(3,:); RAAN_t = COE(4,:); omega_t = COE(5,:);

COEi = inp.Orbits.COEi; COEf = inp.Orbits.COEf; 

XTarget = pars.Orbit.RVf;
int = inp.Orbits.RVi;
targ = inp.Orbits.RVf;

%% Calculating Differences
Rfe = X(end,1:3);
Vfe = X(end,4:6);
RVe = X(end,1:6);
FinalX = X(end,1:6).*[LU,LU,LU,(LU/TU),(LU/TU),(LU/TU)];

DiffR = (norm(XTarget(1:3))-norm(Rfe)).*LU;
DiffV = (norm(XTarget(4:6))-norm(Vfe)).*(LU/TU);
DiffX = norm(XTarget)-norm(RVe);

fprintf('Difference Between Calculated State and Target State Position: %g km \n',DiffR)
fprintf('Difference Between Calculated State and Target State Velocity: %g km/s \n',DiffV)
fprintf('Difference Between Calculated State and Target State Vectors: %g (normalised units) \n',DiffX)
fprintf('\n')
fprintf('Final Mass: %g kg \n',X(end,7)*pars.Unit.MU)
fprintf('Fuel Burnt During Transfer: %g kg \n',260-X(end,7)*pars.Unit.MU)
fprintf('\n')
fprintf('Deployment Parameters: %f \n',int)
fprintf('\n')
fprintf('Final Parameters: %f \n',FinalX)
fprintf('\n')
fprintf('Target Parameters: %f \n',targ)

%% Plot Trajectory
figure('Name','Transfer','NumberTitle','off')
plot3(X(:,1)*LU, X(:,2)*LU, X(:,3)*LU, 'k', 'LineWidth', 0.5)
hold on
plot3(X(1,1)*LU, X(1,2)*LU, X(1,3)*LU, '+r', 'LineWidth', 2)
plot3(X(end,1)*LU, X(end,2)*LU, X(end,3)*LU, '+m', 'LineWidth', 2)
plot3(XTarget(1)*LU, XTarget(2)*LU, XTarget(3)*LU, '+b', 'LineWidth', 2)

xlabel('X (km)'), ylabel('Y (km)'), zlabel('Z (km)'), title('Starlink Transfer Orbit',[char(949) '=1'])
legend('Trajectory','Inital','End','Target')
axis equal
grid on
box on

%% COE plot

figure('Name','Semi-Major Axis','NumberTitle','off')
plot(t_orbit,a_t,'k')
hold on 
yline(COEi(1),'-b'); 
yline(COEf(1),'-r');
title('Semi-Major Axis',[char(949) '=1']); ylabel('km'); xlabel('Time (Hours)'); legend('Trajectory','Inital','Target','Location','best'); grid on

figure('Name','Eccentricity','NumberTitle','off')
plot(t_orbit,e_t,'k')
hold on
yline(COEi(2),'-b'); 
yline(COEf(2),'-r');
title('Eccentricity',[char(949) '=1']); xlabel('Time (Hours)'); legend('Trajectory','Inital','Target','Location','best'); grid on

figure('Name','Inclination','NumberTitle','off')
plot(t_orbit,i_t,'k')
hold on
yline(COEi(3),'-b'); 
yline(COEf(3),'-r');
title('Orbit Inclination',[char(949) '=1']); ylabel('Degrees (\circ)'); xlabel('Time (Hours)'); legend('Trajectory','Inital','Target','Location','best'); grid on

figure('Name','RAAN','NumberTitle','off')
plot(t_orbit,RAAN_t,'k')
hold on 
yline(COEf(4),'-m');
title('RAAN',[char(949) '=1']); ylabel('Degrees (\circ)'); xlabel('Time (Hours)'); legend('Trajectory','Inital & Target','Location','best'); grid on

figure('Name','Argument of Perigee','NumberTitle','off')
plot(t_orbit,omega_t,'k')
hold on
yline(COEi(5),'-b'); 
yline(COEf(5),'-r');
title('Argument of Perigee',[char(949) '=1']); ylabel('Degrees (\circ)'); xlabel('Time (Hours)'); legend('Trajectory','Inital','Target','Location','best'); grid on

%% Individual Plots
figure('Name','Hamiltonian','NumberTitle','off')
plot(t_orbit,H)
title('Control Hamiltonian',[char(949) '=1'])
xlabel('Time (Hours)')
ylabel('Control Hamiltonian Value')
grid on

figure('Name','Switching Function & U','NumberTitle','off')
plot(t_orbit,SF,'LineWidth',1), ylabel('Switching Function (SF)')
hold on
yline(-1)
yline(1)
ylim([-1.1 1.1])
yyaxis right
plot(t_orbit,u,'LineWidth',1), ylabel('Engine Thrust Ratio (u)')
ylim([-0.5 2])
xlabel('Time (Hours)')
grid on 
title('Switching Function',[char(949) '=1'])
legend('Switching Function','','','Engine Thrust Ratio',Location='bestoutside')

figure('Name','Mass','NumberTitle','off')
plot(t_orbit,X(:,7)*MU);
title('Starlink Mass',[char(949) '=1']); xlabel('Time (Hours)'); ylabel('Starlink Mass (kg)')
grid on
