%% Sober Sabes Vibration
% Data Analysis
% Master Project (2nd part) Laura Toron, 2018-19, Sensorimotor Lab

%% reading in data

switch computer
    case 'PCWIN64'
        [data,files] = read_all_data('U:\Internship\Exp_Data_ssv2rep\Exp_Data_ssv2rep','*ssv2rep.DAT'); %specify folder & file names
    case 'MACI64'
        [data,files] = read_all_data('/Volumes/u840143/Internship/Exp_Data_ssv2rep/Exp_Data_ssv2rep','*ssv2rep.DAT'); %specify folder & file names
end

%% check occurrences of different conditions (vibration conditions x target directions)
occur_wish = 12; % how many occurences wanted per condition*target
occur_check = zeros(size(data,2),3,8);
for i = 1:size(data,2)
    for c = 1:3
        for t = 1:8
            occur_check(i,c,t)=size(find(data(i).TrialType==c&data(i).TargetIndex==t-1),1);
        end
    end
end

if occur_check/occur_wish == ones(size(data,2),3,8)
    disp('Occurences are balanced')
end

%% mean duration of frame
mean_dur = zeros(size(data,2),2);
for i = 1:size(data,2)
    frame_dur = zeros(size(data,2),1);
    for trial = 1:size(data(i).FrameData.Frames,1)
        frame_dur(trial)=max(data(i).FrameData.TrialTime(trial,:));
    end
    mean_dur(i,1) = mean(frame_dur); %frame duration
end

for i = 1:size(data,2)
        trial_dur = zeros(size(data,2),1);
    for trial = 1:size(data(i).FrameData.Frames,1)
        trial_dur(trial)=max(data(i).FrameData.TrialTime(trial,data(i).FrameData.State(trial,:)==10))...
            -min(data(i).FrameData.TrialTime(trial,data(i).FrameData.State(trial,:)==9));
    end
    mean_dur(i,2) = mean(trial_dur); %movement states duration

end

%% visually check trajectories for abnormalities
for i = [5,12]
    figure(i)
    hold on
    check_trajectory(data(i),1,1)
    title('biceps and triceps shifted by 30cm in x-axis','FontSize',8)
    suptitle(['subject ',num2str(i),' (final movement angle)'])
    hFig = figure(i);
    set(hFig, 'Position', [500 300 1000 600])
end

%% accelerometers over time (vibration sanity check)

for p = 1:size(data,2)
    figure(1)
    subplot(4,5,p)
    for v = 1:size(unique(data(p).TrialType))
        plot(data(p).FrameData.VibsAccelYY(data(p).TrialType==v),'-','Color',[v/3 0.5 1-v/3])
        hold on
    end
end


%% check different states within one example trial in trajectory
t = 9; %trial number
p = 3; %participant
for i = 1:size(unique(data(p).FrameData.State),1)
    figure(1)
    plot(data(p).FrameData.RobotPosition(t,data(p).FrameData.State(t,:) == i,1),data(p).FrameData.RobotPosition(t,data(p).FrameData.State(t,:) == i,2),'-','Color',[i/12 i/12 i/12])    
    hold on
end

%% miss trials indices (not relevant anymore after error adaptation)

for i = 1:size(data,2)
    data(i).misstrial = zeros(size(data(i).MissTrials,1),1);
    for n = 1:size(data(i).MissTrials,1)
       if n == 1 && data(i).MissTrials(1) > 0
           data(i).misstrial(n) = 1;
       elseif n ~= 1
           if data(i).MissTrials(n) > data(i).MissTrials(n-1)
               data(i).misstrial(n) = 1;
           end
       end
    end
end

%% initial movement direction indices (direction at 40% of maximum speed)

for p = 1:size(data,2)
    %preallocating space in data frame
    data(p).RobotSpeedMax = zeros(data(p).Trials,1);
    data(p).RobotSpeed40 = zeros(data(p).Trials,1);
    for i = 1:size(data(p).RobotSpeedMax,1)
        % maximum speeds
        data(p).RobotSpeedMax(i) = max(data(p).FrameData.RobotSpeed(i,(data(p).FrameData.State(i,:) == 9 | data(p).FrameData.State(i,:) == 10)),[],2);
        MovementStates = (data(p).FrameData.State(i,:) == 9 | data(p).FrameData.State(i,:) == 10);
        % indices of crossing 40% of max speed
        InitialStates = (data(p).FrameData.RobotSpeed(i,:) >= (0.4*data(p).RobotSpeedMax(i)));
        InitialMovementStates = MovementStates.*InitialStates;
        data(p).RobotSpeed40(i) = find(InitialMovementStates == 1,1,'first');
    end
end

%% transform target angles from robot angles to 0 - 360 (counter clockwise, start at right centre)
% also into 180 convention, but with clockwise starting at centre right

for p = 1:size(data,2)
    data(p).TargetAngle360 = zeros(size(data(p).TargetAngle,1),1);
    data(p).TargetAngle180 = zeros(size(data(p).TargetAngle,1),1);
    vector_zero = [1 0 0];% vector of the zero angle
    for t = 1:size(data(p).TargetAngle360,1)
        vector_target = [data(p).TargetPosition(t,1),data(p).TargetPosition(t,2),0]-[0 -3 0];
        if data(p).TargetPosition(t,2)+3 >= 0
            data(p).TargetAngle360(t) = atan2d(norm(cross(vector_target,vector_zero)),dot(vector_target,vector_zero));
            data(p).TargetAngle180(t) = atan2d(norm(cross(vector_target,vector_zero)),dot(vector_target,vector_zero));
        else
            data(p).TargetAngle360(t) = 360-atan2d(norm(cross(vector_target,vector_zero)),dot(vector_target,vector_zero));
            data(p).TargetAngle180(t) = -atan2d(norm(cross(vector_target,vector_zero)),dot(vector_target,vector_zero));
        end
    end
end

%% calculate angular difference between initial movement angle and target angle
for p = 1:size(data,2)
    data(p).angle_40 = zeros(size(data(p).TargetAngle360,1),1);
    data(p).angle_diff_40 = zeros(size(data(p).TargetAngle360,1),1);
    vector_zero = [1 0 0];% vector of the zero angle
    for t = 1:size(data(p).TargetAngle360,1)
        vector_40 = [data(p).FrameData.RobotPosition(t,data(p).RobotSpeed40(t),1),data(p).FrameData.RobotPosition(t,data(p).RobotSpeed40(t),2),0]-[0 -3 0];
        %compute the angle of the initial movement
        if data(p).FrameData.RobotPosition(t,data(p).RobotSpeed40(t),2)+3 >= 0
            data(p).angle_40(t) = atan2d(norm(cross(vector_40,vector_zero)),dot(vector_40,vector_zero));
        else
            data(p).angle_40(t) = 360-atan2d(norm(cross(vector_40,vector_zero)),dot(vector_40,vector_zero));
        end
        
        data(p).angle_40_vel(t) = atan2(data(p).FrameData.RobotVelocity(t,data(p).RobotSpeed40(t),2),...
            data(p).FrameData.RobotVelocity(t,data(p).RobotSpeed40(t),1))*180/pi;
        if data(p).angle_40_vel(t)<0
            data(p).angle_40_vel(t)=360+data(p).angle_40_vel(t);
        end
        % compute difference vector between target angle and actual angle
        % as a positive errror at angle 0 results in target angles at around
        % 360°, we need an exemption for these cases
        data(p).angle_diff_40(t) = (data(p).angle_40_vel(t) - data(p).TargetAngle360(t));
        if data(p).angle_diff_40(t) > 180
            data(p).angle_diff_40(t) = 360 -data(p).angle_diff_40(t);
        elseif data(p).angle_diff_40(t) < -180
            data(p).angle_diff_40(t) = data(p).angle_diff_40(t)+360;  
        end

        %exclude bigger than 45° offset
%         if abs(data(p).angle_diff_40(t)) > 45
%             data(p).angle_diff_40(t) = 999;
%         end
    end
    
end

%% std error of the means for initial movement

% compute means of errors
for p = 1:size(data,2)
    data(p).angle_diff_40_mean = zeros(8,3);
    data(p).angle_diff_40_median = zeros(8,3);
    for a = 1:size(unique(data(p).TargetAngle180),1)
        for v = 1:size(unique(data(p).TrialType),1)
            data(p).angle_diff_40_mean(a,v) = mean(data(p).angle_diff_40(data(p).TrialType==v&data(p).TargetAngle180<(-179+45*a)&data(p).angle_diff_40~=999&data(p).TargetAngle180>(-181+45*a)));
            data(p).angle_diff_40_median(a,v) = median(data(p).angle_diff_40(data(p).TrialType==v&data(p).TargetAngle180<(-179+45*a)&data(p).angle_diff_40~=999&data(p).TargetAngle180>(-181+45*a)));
            % second line is without miss trials
            %data(p).angle_diff_40_mean(a,v) = mean(data(p).angle_diff_40(data(p).TrialType==v&data(p).TargetAngle180==a&data(p).misstrial == 0));
        end
    end

    % compute standard error of mean
    data(p).ad40_sem = zeros(8,3);
    for a = 1:size(unique(data(p).TargetAngle180),1)
        for v = 1:size(unique(data(p).TrialType),1)
            data(p).ad40_sem(a,v) = std(data(p).angle_diff_40(data(p).TrialType==v&data(p).TargetAngle180<(-179+45*a)&data(p).angle_diff_40~=999&data(p).TargetAngle180>(-181+45*a)))/sqrt(size((data(p).angle_diff_40(data(p).TrialType==v&data(p).TargetAngle180<(-179+45*a)&data(p).TargetAngle180>(-181+45*a))),1));
            % second line is without miss trials 
            %data(p).ad40_sem(a,v) = std(data(p).angle_diff_40(data(p).TrialType==v&data(p).TargetAngle180==a&data(p).misstrial==0))/sqrt(size((data(p).angle_diff_40(data(p).TrialType==v&data(p).TargetAngle180==a&data(p).misstrial == 0)),1));
        end
    end
end

%% std error of the means for final movement

% compute means of errors
for p = 1:size(data,2)
    data(p).angle_diff_fin_mean = zeros(8,3);
    for a = 1:size(unique(data(p).TargetAngle180),1)
        for v = 1:size(unique(data(p).TrialType),1)
            data(p).angle_diff_fin_mean(a,v) = mean(data(p).angle_diff_fin(data(p).TrialType==v&data(p).TargetAngle180<(-179+45*a)&data(p).TargetAngle180>(-181+45*a)));
            % second line is without miss trials
            %data(p).angle_diff_fin_mean(a,v) = mean(data(p).angle_diff_fin(data(p).TrialType==v&data(p).TargetAngle180==a&data(p).misstrial == 0));
        end
    end

    % compute standard error of mean
    data(p).adfin_sem = zeros(8,3);
    for a = 1:size(unique(data(p).TargetAngle180),1)
        for v = 1:size(unique(data(p).TrialType),1)
            data(p).adfin_sem(a,v) = std(data(p).angle_diff_fin(data(p).TrialType==v&data(p).TargetAngle180<(-179+45*a)&data(p).TargetAngle180>(-181+45*a)))/sqrt(size((data(p).angle_diff_fin(data(p).TrialType==v&data(p).TargetAngle180<(-179+45*a)&data(p).TargetAngle180>(-181+45*a))),1));
            % second line is without miss trials 
            %data(p).adfin_sem(a,v) = std(data(p).angle_diff_fin(data(p).TrialType==v&data(p).TargetAngle180==a&data(p).misstrial==0))/sqrt(size((data(p).angle_diff_fin(data(p).TrialType==v&data(p).TargetAngle180==a&data(p).misstrial == 0)),1));
        end
    end
end

%% plot the errors per trial

for p = 1:size(data,2)
    figure(p)
    subplot(1,3,1)
    plot(data(p).TargetAngle180(data(p).TrialType==1),data(p).angle_diff_40(data(p).TrialType==1),'o')
    axis([0 360 -30 30])
    ylabel('error in degrees')
    title('no vibration')
    subplot(1,3,2)
    plot(data(p).TargetAngle180(data(p).TrialType==2),data(p).angle_diff_40(data(p).TrialType==2),'o')
    axis([0 360 -30 30])
    xlabel('target angle')
    title('triceps')
    subplot(1,3,3)
    plot(data(p).TargetAngle180(data(p).TrialType==3),data(p).angle_diff_40(data(p).TrialType==3),'o')
    axis([0 360 -30 30])
    title('biceps')
end

%% plot means of the errors (initial)
for p = 1:size(data,2)
    figure(p)
    subplot(1,2,2)
    hold on
    errorbar(unique(data(p).TargetAngle180),data(p).angle_diff_40_mean(:,1),data(p).ad40_sem(:,1),'b-')
    errorbar(unique(data(p).TargetAngle180),data(p).angle_diff_40_mean(:,2),data(p).ad40_sem(:,2),'g-')
    errorbar(unique(data(p).TargetAngle180),data(p).angle_diff_40_mean(:,3),data(p).ad40_sem(:,3),'r-')
    xlabel('target angle')
    ylabel('error in degrees')
    %title(['subject ',num2str(p)])
    legend('no vibration','triceps','biceps')

end
%suptitle('Mean error per target and standard error of initial direction')

%% plot summary means of errors (initial)

% compute summary means
angle_diff_40_mean_all = zeros(size(unique(data(1).TargetIndex),1),size(unique(data(1).TrialType),1),size(data,2));
ad40_sem_all = zeros(size(unique(data(1).TargetIndex),1),size(unique(data(1).TrialType),1),size(data,2));
for p = 1:size(data,2)
    angle_diff_40_mean_all(:,:,p) = data(p).angle_diff_40_mean;
    ad40_sem_all(:,:,p) = data(p).ad40_sem;
end

angle_diff_40_mean_sum = mean(angle_diff_40_mean_all,3);
ad40_sem_sum = mean(ad40_sem_all,3);

figure(1)
%subplot(1,2,2)
hold on
errorbar(unique(data(1).TargetAngle180),angle_diff_40_mean_sum(:,1),ad40_sem_sum(:,1),'b-')
errorbar(unique(data(1).TargetAngle180),angle_diff_40_mean_sum(:,2),ad40_sem_sum(:,2),'g-')
errorbar(unique(data(1).TargetAngle180),angle_diff_40_mean_sum(:,3),ad40_sem_sum(:,3),'r-')
xlabel('target angle')
ylabel('error in degrees')
title('Group mean error per target and standard error of initial direction')
legend('no vibration','triceps','biceps')
%suptitle('Group-level data')

%% plot means of the errors (final)
for p = 1:size(data,2)
    figure(p)
    subplot(1,2,2)
    hold on
    errorbar(unique(data(1).TargetAngle180),data(p).angle_diff_fin_mean(:,1),data(p).adfin_sem(:,1),'b-')
    errorbar(unique(data(1).TargetAngle180),data(p).angle_diff_fin_mean(:,2),data(p).adfin_sem(:,2),'g-')
    errorbar(unique(data(1).TargetAngle180),data(p).angle_diff_fin_mean(:,3),data(p).adfin_sem(:,3),'r-')
    xlabel('target angle')
    ylabel('error in degrees')
    %title(['subject ',num2str(p)])
    legend('no vibration','triceps','biceps')

end
%suptitle('Mean error per target and standard error of initial direction')

%% plot summary means of errors (final)

% compute summary means
angle_diff_fin_mean_all = zeros(size(unique(data(1).TargetIndex),1),size(unique(data(1).TrialType),1),size(data,2));
adfin_sem_all = zeros(size(unique(data(1).TargetIndex),1),size(unique(data(1).TrialType),1),size(data,2));
for p = 1:size(data,2)
    angle_diff_fin_mean_all(:,:,p) = data(p).angle_diff_fin_mean;
    adfin_sem_all(:,:,p) = data(p).adfin_sem;
end

angle_diff_fin_mean_sum = mean(angle_diff_fin_mean_all,3);
adfin_sem_sum = mean(adfin_sem_all,3);

figure(1)
%subplot(1,2,2)
hold on
errorbar(unique(data(1).TargetAngle),angle_diff_fin_mean_sum(:,1),adfin_sem_sum(:,1),'b-')
errorbar(unique(data(1).TargetAngle),angle_diff_fin_mean_sum(:,2),adfin_sem_sum(:,2),'g-')
errorbar(unique(data(1).TargetAngle),angle_diff_fin_mean_sum(:,3),adfin_sem_sum(:,3),'r-')
xlabel('target angle')
ylabel('error in degrees')
title('Group mean error per target and standard error of final direction')
legend('no vibration','triceps','biceps')
%suptitle('Group-level data')

%% errors over time
for i = 1:size(data,2)
    figure(1)
    subplot(4,5,i)
    plot(data(i).angle_diff_40)
end
suptitle('Angular initial error per subject over trials')

for i = 1:size(data,2)
    figure(2)
    subplot(4,5,i)
    plot(data(i).angle_diff_fin)
end
suptitle('Angular final error per subject over trials')