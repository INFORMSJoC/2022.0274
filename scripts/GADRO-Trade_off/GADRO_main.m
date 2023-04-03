%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 23/10/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This function is used to compare the quality of GRnO with different theta and target and WDRO with different theta.

clear;
clc;

tic

% Get acess to the current path and add the files in the 'main' folder to path
current_path = pwd; 
[parent_path, ~, ~] = fileparts(current_path); 
addpath(strcat(parent_path, "\main"));

%% Output
% Total cost and probability of exceeding target under different values of gamma

%% Input Parameters and initialization

N = 10 ;                                                                         % dimension of uncertainty
S = 20 ;                                                                          % in-sample data point
S1 = 2000 ;                                                                  % out-sample data point
D = 40 ;
D1 = 40 ;                                                                   % upper bound of decision and uncertainty
c1 = 10*ones(N,1)  ;                                                      % first stage unit cost
c2 = 30*ones(N,1) ;                                                       % emergency unit cost
mu = 20 ;                                                                     % mean value of demand
sigma = 15 ;                                                                % standard deviation of demand
tolerance = 10^(-10);

t = xlsread('distance.xlsx','A2:J11');                          % distance matrix
d= xlsread('d_insample.xlsx','A2:T11');                     % training sample matrix
d1 = xlsread('d_outsample.xlsx','A2:BXX11');           % testing sample matrix

theta = [0, 1, 2] ;

%% Out-of-Sample Testing
for m = 1 : 3 % iterate theta
    
    %% Solve the WDRO model
    [x_SAA(:,m),opt(m),lambda(m)] = WassersteinDRO(theta(m),N,S,D,d,c1,c2,t);
    
    %% Solve the GDRO model
    for n = 1 : 101
        k(m,n) = (1 - ((n-1)/100)^(2/3))^(3/2)*lambda(m)  ;
        [x(:,m,n),TotalCost_insample(m,n)] = GDRnO(N,S,D,D1,d,theta(m),c1,c2,t,k(m,n)) ;
        T(m,n) = TotalCost_insample(m,n) - c1'*x(:,m,n) ;
        
        %% Second-stage cost under out-of-sample distribution
        second_stage_objective_value(:,m,n) = SecondStage(N, S1, d1, x(:,m,n), c2, t);
        SecondStageCost(m,n) = mean(second_stage_objective_value(:,m,n));
        for s = 1 : S1
            if second_stage_objective_value(s,m,n) <= T(m,n) + tolerance
                indicator(s,m,n) = 0;
            else
                indicator(s,m,n) = 1;
            end
        end
        
       TotalCost_GDRO(m,n) = SecondStageCost(m,n) + c1'*x(:,m,n);
       Probability(m,n) = mean(indicator(:,m,n));
       fprintf('The current iteration = %g\n',n)
    end
end

toc
