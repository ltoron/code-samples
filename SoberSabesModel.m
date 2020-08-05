%% Velocity command model (Sober & Sabes, 2003), extended with a shift in proprioception
% as implemented by JK as Jupyter notebook, re-implemented to Matlab
% added proprioceptive shift and angular component of shift

%% Overview

% movement vector and inverse model (the two estimated positions of x)
% x_mv_est = a_mv * x_vis_est + (1 - a_mv) * x_prop_est; % movement vector
% x_inv_est = a_inv * x_vis_est + (1 - a_inv) * x_prop_est; % inverse model
%DELETE LATER FOLLOWING LINE
axs = 1;
% Subject's parameters and resulting estimates
L = [27,33];
ArmSign = 1;
% Experimental context: Let's define that the subject's shoulder is at (0,0),
% and the center of the 18 cm diameter target ring at (-10,40).
tgtOrigin = [-16, 42];

a_MV = 0.8;
a_INV = 0.3;
tgtRad = 18;

true_th = iK(tgtOrigin(1), tgtOrigin(2), L);
x_prop = [tgtOrigin(1),  tgtOrigin(2)]';
x_vis  = [tgtOrigin(1)+6,tgtOrigin(2)]';

%% plot the arm configuration and all targets
% figure(figsize=(8,5))
figure(1)
plotExpContext(tgtRad, x_vis, x_prop, axs, a_MV, a_INV, L, tgtOrigin, true)

%% plot a re-creation of figure 4 in Sober & Sabes (2003)
figure(2)
% fig = figure(figsize=(14,9))
fs = 12;
supptitle('Re-creation of figure 4 in Sober & Sabes (2003)',10)
% first, plot the leftward visual shift in black
x_prop = [tgtOrigin(1), tgtOrigin(2)]';
x_vis  = [tgtOrigin(1)-6,tgtOrigin(2)]';
subplot(2,2,1)
plotModel(0, 0, x_vis, x_prop, tgtRad,'k', tgtOrigin, L, ArmSign, true_th,true)
title('\alpha_{MV} = 0','FontSize',fs)
ylabel('\alpha_{INV} = 0','FontSize',fs)
subplot(2,2,2)
plotModel(0.7, 0, x_vis, x_prop, tgtRad,'k', tgtOrigin, L, ArmSign, true_th,true)
title('\alpha_{MV} = 0.7','FontSize',fs)
subplot(2,2,3)
plotModel(0, 0.7, x_vis, x_prop, tgtRad,'k', tgtOrigin, L, ArmSign, true_th,true)
ylabel('\alpha_{INV} = 0.7','FontSize',fs)
subplot(2,2,4)
plotModel(0.7, 0.7, x_vis, x_prop, tgtRad,'k', tgtOrigin, L, ArmSign, true_th,true)

% switch to a rightward visual shift, plotted in grey
x_prop = [tgtOrigin(1), tgtOrigin(2)]';
x_vis  = [tgtOrigin(1)+6,tgtOrigin(2)]';
subplot(2,2,1)
plotModel(0, 0, x_vis, x_prop, tgtRad,[0.5 0.5 0.5], tgtOrigin, L, ArmSign, true_th,true) %gray
subplot(2,2,2)
plotModel(0.7, 0, x_vis, x_prop, tgtRad,[0.5 0.5 0.5], tgtOrigin, L, ArmSign, true_th,true) %gray
subplot(2,2,3)
plotModel(0, 0.7, x_vis, x_prop, tgtRad,[0.5 0.5 0.5], tgtOrigin, L, ArmSign, true_th,true) %gray
subplot(2,2,4)
plotModel(0.7, 0.7, x_vis, x_prop, tgtRad,[0.5 0.5 0.5], tgtOrigin, L, ArmSign, true_th,true) %gray
a = axes; a.Visible = 'off';
y = ylabel('Shift-induced error [deg]','FontSize',15); y.Visible = 'on';
x = xlabel('Target direction [deg]','FontSize',15); x.Visible = 'on';
% In S&S 2003, fig 4: Black lines, leftward shift (CL); gray lines, rightward shift (CR).

%% Plotting across possible shift angles

figure(3)
subplot(2,2,1)
hold on
x_prop = [tgtOrigin(1),  tgtOrigin(2)]';
for i = [-6, 6]
    x_vis  = [tgtOrigin(1)+i,tgtOrigin(2)]';
    plotModel(0.8, 0.3, x_vis, x_prop, tgtRad,[((i+abs(i))/abs(i*3)) ((i+abs(i))/abs(i*3)) ((i+abs(i))/abs(i*3))], tgtOrigin, L, ArmSign, true_th,true)
end
xlabel('Target direction [deg]')
ylabel('Shift-induced error [deg]')
title('A. Visual shift (+6cm)')
legend('0°','180°')
legend('Location','east')
%legend('boxoff')

subplot(2,2,2)
hold on
propShift = 6;
x_vis  = [tgtOrigin(1),tgtOrigin(2)]';

for i = [45, 225]
    x_prop = [tgtOrigin(1)+propShift*cos(deg2rad(i)),tgtOrigin(2)+propShift*sin(deg2rad(i))]';
    plotModel(0.8, 0.3, x_vis, x_prop, tgtRad,[i/360 i/360 i/360], tgtOrigin, L, ArmSign, true_th,true)
end
xlabel('Target direction [deg]')
ylabel('Shift-induced error [deg]')
title('B. Proprioceptive shift (+6cm)')
legend('45°','225°')
%legend('0°','45°','90°','135°','180°','225°','270°','315°')
legend('Location','east')
%legend('boxoff')

subplot(2,2,3) %vis angle
n_plot = 60;
vis_shift = zeros(n_plot,50);
visShift = 6;
t=0;

for as = linspace(0,359,n_plot)
    t=t+1;
    x_vis = [tgtOrigin(1)+visShift*cos(deg2rad(as)),tgtOrigin(2)+visShift*sin(deg2rad(as))]';
    x_prop = [tgtOrigin(1),  tgtOrigin(2)]';  
    result_t = plotModel(0.8, 0.3, x_vis, x_prop, tgtRad,[0.5 0.5 0.5], tgtOrigin, L, ArmSign, true_th,false);
    for k = 1:size(result_t,2)
       if result_t(2,k) > pi
           result_t(2,k) = result_t(2,k)-2*pi;
       elseif result_t(2,k) < -pi
           result_t(2,k) = result_t(2,k)+2*pi;
       end
    end
    vis_shift(t,:) = rad2deg(result_t(2,:));
end

waterfall(linspace(-180,180,50),linspace(0,359,60),vis_shift)
hold on
plot([-180,180],[0,0], 'k:', 'LineWidth',1)
xlabel('Target direction [deg]')
ylabel('Angle of visual shift [deg]')
zlabel('Shift-induced error [deg]')
% xlim([0,50])
% ylim([0,n_plot-1])
% zlim([-30,30])
% xticks(linspace(-180, 180, 8+1))
title('C. Visual shift (+6cm)')

subplot(2,2,4) %prop angle
n_plot = 60;
prop_shift = zeros(n_plot,50);
propShift =6;
t=0;
for as = linspace(0,359,n_plot)
    t=t+1;
    x_vis = [tgtOrigin(1),  tgtOrigin(2)]';
    x_prop = [tgtOrigin(1)+propShift*cos(deg2rad(as)),tgtOrigin(2)+propShift*sin(deg2rad(as))]';
    result_t = plotModel(0.8, 0.3, x_vis, x_prop, tgtRad,[0.5 0.5 0.5], tgtOrigin, L, ArmSign, true_th,false);
    for k = 1:size(result_t,2)
       if result_t(2,k) > pi
           result_t(2,k) = result_t(2,k)-2*pi;
       elseif result_t(2,k) < -pi
           result_t(2,k) = result_t(2,k)+2*pi;
       end
    end
    prop_shift(t,:) = rad2deg(result_t(2,:));
end

waterfall(linspace(-180,180,50),linspace(0,359,60),prop_shift)
hold on
plot([-180,180],[0,0], 'k:', 'LineWidth',1)
xlabel('Target direction [deg]')
ylabel('Angle of proprioceptive shift [deg]')
zlabel('Shift-induced error [deg]')
title('D. Proprioceptive shift (+6cm)')
% xlim([0,50])
% ylim([0,n_plot-1])
% zlim([-30,30])
% xticks(linspace(-180, 180, 8+1))

%suptitle('Visual and proprioceptive shift-induced errors in initial target direction')

%% Different magnitudes of bias

figure(1)
hold on
propShift = 2;
x_vis  = [tgtOrigin(1),tgtOrigin(2)]';

for i = 0:1:7
    propShift=i;
    x_prop = [tgtOrigin(1)+propShift*cos(deg2rad(45)),tgtOrigin(2)+propShift*sin(deg2rad(45))]';
    plotModel(0.8, 0.3, x_vis, x_prop, tgtRad,[i/7 i/7 i/7], tgtOrigin, L, ArmSign, true_th,true)
end
xlabel('Target direction [deg]')
ylabel('Shift-induced error [deg]')
%title('Proprioceptive shift (45°), \alpha_{MV} = 0.8, \alpha_{INV} = 0.3')
legend('0cm','1cm','2cm','3cm','4cm','5cm','6cm','7cm')
legend('Location','eastoutside')
%legend('boxoff')
