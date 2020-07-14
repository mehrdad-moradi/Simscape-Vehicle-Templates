% Code to plot simulation results from sm_car
%% Plot Description:
%
% Plot results of vehicle test: position, x and y velocity components,
% vehicle speed, and steering input.
%
% Copyright 2018-2020 The MathWorks, Inc.

% Check for simulation results
if ~exist('logsout_sm_car', 'var')
    error('logsout_sm_car data not available.')
end


% Reuse figure if it exists, else create new figure
if ~exist('h1_sm_car', 'var') || ...
        ~isgraphics(h1_sm_car, 'figure')
    h1_sm_car = figure('Name', 'sm_car');
end
figure(h1_sm_car)
clf(h1_sm_car)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
logsout_VehBus = logsout_sm_car.get('VehBus');

logsout_xSteerFA = logsout_VehBus.Values.Chassis.SuspF.Steer.xRack;
logsout_xSteerRA = logsout_VehBus.Values.Chassis.SuspR.Steer.xRack;
logsout_vxVeh = logsout_VehBus.Values.World.vx;
logsout_vyVeh = logsout_VehBus.Values.World.vy;
logsout_sVeh = sqrt(logsout_vxVeh.Data.^2+logsout_vyVeh.Data.^2);
logsout_xCar = logsout_VehBus.Values.World.x;
logsout_yCar = logsout_VehBus.Values.World.y;

logsout_px0 = logsout_xCar.Data(1);
logsout_py0 = logsout_yCar.Data(1);

% Plot results
simlog_handles(1) = subplot(2, 2, 1);
plot(logsout_xCar.Data-logsout_px0, logsout_yCar.Data-logsout_py0, 'LineWidth', 1)
axis equal
grid on
title('Position')
ylabel('Position (m)')
xlabel('Position (m)')

simlog_handles(2) = subplot(2, 2, 2);
yyaxis left
plot(logsout_xSteerFA.Time, logsout_xSteerFA.Data,'Color',temp_colororder(1,:), 'LineWidth', 1)
hold on
plot(logsout_xSteerRA.Time, logsout_xSteerRA.Data,'--','Color',temp_colororder(3,:), 'LineWidth', 1)
hold off
ylim_curr = get(gca,'YLim');
set(gca,'YLim',[min(-1e-3,ylim_curr(1)) max(1e-3,ylim_curr(2))])
ylabel('Position (m)')
yyaxis right
plot(logsout_xSteerFA.Time,1:length(logsout_xSteerFA.Time))
ylabel('# Steps')
grid on
legend({'Front','Rear'},'Location','SouthEast');
title('Steering Rack Pos | # Steps')
xlabel('Time (s)')

simlog_handles(3) = subplot(2, 2, 3);
plot(logsout_vxVeh.Time, logsout_sVeh*3.6, 'LineWidth', 1)
grid on
title('Vehicle Speed')
ylabel('Speed (km/hr)')
xlabel('Time (s)')

simlog_handles(4) = subplot(2, 2, 4);
yyaxis left
plot(logsout_vxVeh.Time, logsout_vxVeh.Data*3.6,'Color',temp_colororder(1,:), 'LineWidth', 1)
ylabel('Speed (km/hr)')
yyaxis right
plot(logsout_vyVeh.Time, logsout_vyVeh.Data*3.6, 'LineWidth', 1)
grid on
title('Vehicle Speed (x, y)')
xlabel('Time (s)')
legend({'Vx','Vy'},'Location','South');

subplot(2,2,2)
temp_tire_sys = find_system(bdroot,'LookUnderMasks','on','FollowLinks','on','Name','Tire FL');
temp_tire_sys_vehi = find(contains(temp_tire_sys,'/Vehicle/Chassis/'));
temp_tirevar = char(get_param(temp_tire_sys(temp_tire_sys_vehi),'ActiveVariant'));
text(0.05,0.85,sprintf('Tire %s\nSteps: %d',temp_tirevar,length(logsout_vxVeh.Time)),'Units','Normalized','Color',[1 1 1]*0.5);
clear temp_tire_sys temp_tirevar

subplot(2,2,1)
text(0.05,0.2,sprintf('xFinal: %0.2f m\nyFinal: %0.2f m',...
    logsout_xCar.Data(end)-logsout_px0,logsout_yCar.Data(end)-logsout_py0),'Units','Normalized','Color',[1 1 1]*0.5);
if(isfield(Vehicle,'config'))
    config_string = Vehicle.config;
else
    config_string = 'custom';
end

text(0.05,0.85,sprintf('%s\n%s',strrep(config_string,'_','\_'),get_param(bdroot,'Solver')),...
    'Color',[1 1 1]*0.5,'Units','Normalized')

subplot(2,2,3)
text(0.05,0.85,sprintf('Elapsed Time:\n%0.2f sec',...
    Elapsed_Sim_Time),'Units','Normalized','Color',[1 1 1]*0.5);

trailer_type = sm_car_vehcfg_getTrailerType(bdroot);
if(~strcmpi(trailer_type,'none'))
    trailer_type = Trailer.config;
end
text(0.05,0.1,sprintf('Trailer: %s',strrep(trailer_type,'_','\_')),'Units','Normalized','Color',[1 1 1]*0.5);

delvars = setdiff(who('logsout_*'),'logsout_sm_car');
clear(delvars{:},'delvars');

clear simlog_handles temp_colororder

