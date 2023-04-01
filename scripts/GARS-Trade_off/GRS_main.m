%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 04/10/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This function is used to compare the quality of GRS with different theta and target and RS with different theta.

clear;
clc;

tic

%% Parameters and initialization

N = 10 ;                                                                         % dimension of uncertainty
S = 20 ;                                                                          % in-sample data point
S1 = 2000 ;                                                                     % out-sample data point
D = 40 ;
D1 = 40 ;                                                                   % upper bound of decision and uncertainty
% load('C:\Users\DELL\Desktop\WDRO&GDRO\210620\distance.mat')
t = xlsread('C:\Users\liufe\Desktop\distance.xlsx','A2:J11');
d= xlsread('C:\Users\liufe\Desktop\d_insample.xlsx','A2:T11');
d1 = xlsread('C:\Users\liufe\Desktop\d_outsample.xlsx','A2:BXX11');
c1 = 10*ones(N,1)  ;                                                      % first stage unit cost
c2 = 30*ones(N,1) ;                                                       % emergency unit cost
mu = 20 ;                                                                     % mean value of demand
sigma = 15 ;                                                                % standard deviation of demand
theta = [0 1 2 5] ;
[x_SAA,opt] = baseline(N,S,D,d,c1,c2,t);
obj_SAA = SecondStage(N, S1, d1, x_SAA, c2, t);
SAA = c1'*x_SAA + mean(obj_SAA);

%% theta = 0
T1 = [1:0.01:1.10,1.12:0.02:1.36]*opt ;
%     theta(:,n) = [0, 0.01*w_distance(n),0.05*w_distance(n), 0.10*w_distance(n), 0.20*w_distance(n)];

%% Out-of-Sample Testing
for j = 1 : 24
    %Solve the GDRO model
    [k1(j),x1(:,j),~] = GlobalRnO(N,S,D,D1,d,theta(1),T1(j),c1,c2,t) ;
    
    %Second-stage cost
    second_stage_value1(:,j) = SecondStage(N, S1, d1, x1(:,j), c2, t);
    TotalCost1(:,j) = c1'*x1(:,j) + second_stage_value1(:,j);
    
    SecondStageCost1(j) = mean(second_stage_value1(:,j));
    TotalCost_GRS1(j) = SecondStageCost1(j) + c1'*x1(:,j);
    
    for s = 1 : S1
        if TotalCost1(s,j) <=T1(j)
            indicator(s) = 0 ;
        else
            indicator(s) = 1 ;
        end
        deviation(s) = ( T1(j) - TotalCost_GRS1(j) )/T1(j);
    end
    
    probability1(j) = mean(indicator);
    normalize_cost1(j) = TotalCost_GRS1(j)/SAA ;
    shortage1(j) = mean(deviation(deviation>0)) ;
    surplus1(j) = - mean(deviation(deviation<0)) ;
    Deviation1(j) = mean(deviation) ;
    fprintf('Iterations for target = %g\n',j)
end

%% theta = 1
T2= [1.0158,1.02:0.01:1.10,1.12:0.02:1.36]*opt ;
%     theta(:,n) = [0, 0.01*w_distance(n),0.05*w_distance(n), 0.10*w_distance(n), 0.20*w_distance(n)];

%% Out-of-Sample Testing
for j = 1 : length(T2)
    %Solve the GDRO model
    [k2(j),x2(:,j),~] = GlobalRnO(N,S,D,D1,d,theta(2),T2(j),c1,c2,t) ;
    
    %Second-stage cost
    second_stage_value2(:,j) = SecondStage(N, S1, d1, x2(:,j), c2, t);
    TotalCost2(:,j) = c1'*x2(:,j) + second_stage_value2(:,j);
    
    SecondStageCost2(j) = mean(second_stage_value2(:,j));
    TotalCost_GRS2(j) = SecondStageCost2(j) + c1'*x2(:,j);
    
    for s = 1 : S1
        if TotalCost2(s,j) <=T2(j)
            indicator(s) = 0 ;
        else
            indicator(s) = 1 ;
        end
        deviation(s) = ( T2(j) - TotalCost_GRS2(j) )/T2(j);
    end
    
    probability2(j) = mean(indicator);
    normalize_cost2(j) = TotalCost_GRS2(j)/SAA ;
    shortage2(j) = mean(deviation(deviation>0)) ;
    surplus2(j) = - mean(deviation(deviation<0)) ;
    Deviation2(j) = mean(deviation) ;
    fprintf('Iterations for target = %g\n',j)
end

%% theta = 2
T3 = [1.0341,1.04:0.01:1.10,1.12:0.02:1.36]*opt ;
%     theta(:,n) = [0, 0.01*w_distance(n),0.05*w_distance(n), 0.10*w_distance(n), 0.20*w_distance(n)];

%% Out-of-Sample Testing
for j = 1 : length(T3)
    %Solve the GDRO model
    [k3(j),x3(:,j),~] = GlobalRnO(N,S,D,D1,d,theta(3),T3(j),c1,c2,t) ;
    
    %Second-stage cost
    second_stage_value3(:,j) = SecondStage(N, S1, d1, x3(:,j), c2, t);
    TotalCost3(:,j) = c1'*x3(:,j) + second_stage_value3(:,j);
    
    SecondStageCost3(j) = mean(second_stage_value3(:,j));
    TotalCost_GRS3(j) = SecondStageCost3(j) + c1'*x3(:,j);
    
    for s = 1 : S1
        if TotalCost3(s,j) <=T3(j)
            indicator(s) = 0 ;
        else
            indicator(s) = 1 ;
        end
        deviation(s) = ( T3(j) - TotalCost_GRS3(j) )/T3(j);
    end
    
    probability3(j) = mean(indicator);
    normalize_cost3(j) = TotalCost_GRS3(j)/SAA ;
    shortage3(j) = mean(deviation(deviation>0)) ;
    surplus3(j) = - mean(deviation(deviation<0)) ;
    Deviation3(j) = mean(deviation) ;
    fprintf('Iterations for target = %g\n',j)
end

%% theta = 5
T4 = [1.084,1.09,1.10,1.12:0.02:1.36]*opt ;
%     theta(:,n) = [0, 0.01*w_distance(n),0.05*w_distance(n), 0.10*w_distance(n), 0.20*w_distance(n)];

%% Out-of-Sample Testing
for j = 1 : length(T4)
    %Solve the GDRO model
    [k4(j),x4(:,j),~] = GlobalRnO(N,S,D,D1,d,theta(4),T4(j),c1,c2,t) ;
    
    %Second-stage cost
    second_stage_value4(:,j) = SecondStage(N, S1, d1, x4(:,j), c2, t);
    TotalCost4(:,j) = c1'*x4(:,j) + second_stage_value4(:,j);
    
    SecondStageCost4(j) = mean(second_stage_value4(:,j));
    TotalCost_GRS4(j) = SecondStageCost4(j) + c1'*x4(:,j);
    
    for s = 1 : S1
        if TotalCost4(s,j) <=T4(j)
            indicator(s) = 0 ;
        else
            indicator(s) = 1 ;
        end
        deviation(s) = ( T4(j) - TotalCost_GRS4(j) )/T4(j);
    end
    
    probability4(j) = mean(indicator);
    normalize_cost4(j) = TotalCost_GRS4(j)/SAA ;
    shortage4(j) = mean(deviation(deviation>0)) ;
    surplus4(j) = - mean(deviation(deviation<0)) ;
    Deviation4(j) = mean(deviation) ;
    fprintf('Iterations for target = %g\n',j)
end

toc