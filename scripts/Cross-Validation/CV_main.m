%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 05/01/2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This function is used to tune a proper gamma.

clear;
clc;

tic

% Get acess to the current path and add the files in the 'main' folder to path
current_path = pwd; 
[parent_path, ~, ~] = fileparts(current_path); 
addpath(strcat(parentpath, "\main"));

%% Output
% Total cost and probability of exceeding target under different values of gamma

%% Input  Parameters and initialization

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

%% Partition Data
di(:,:,1) = d(:, [1:5, 11:20]);
do(:,:,1) = d(:,6:10);
di(:,:,2) = d(:, [1:10, 16:20]);
do(:,:,2) = d(:,11:15);
di(:,:,3) = d(:, 1:15);
do(:,:,3) = d(:,16:20);
di(:,:,4) = d(:, 6:20);
do(:,:,4) = d(:,1:5);

theta = 2 ;

[x_SAA, opt, lambda] = WassersteinDRO(theta, N, S, D, d, c1, c2, t);
target = opt - c1'*x_SAA;

k = [linspace(0, 37, 75), lambda];

%% 4-fold CV
for m = 1 : 76 % iterate gamma

    %% Solve the GDRO model
    for n = 1 : 4   % cross-validate
        [x(:,m,n),TotalCost_insample(m,n)] = GDRnO(N,S-5,D,D1,di(:,:,n),theta,c1,c2,t,k(m)) ;
        
        %% out-of-sample performance
        second_stage_objective_value(:,m,n) = SecondStage(N, 5, do(:,:,n), x(:,m,n), c2, t);
        for i = 1: 5
            if second_stage_objective_value(i,m,n) <= target
                probability(i,m,n) = 0;
            else
                probability(i,m,n) = 1;
            end
        end
        SecondStageCost(m,n) = mean(second_stage_objective_value(:,m,n));
        
        TotalCost_GDRO(m,n) = SecondStageCost(m,n) + c1'*x(:,m,n);

        Probability(m, n) = mean(probability(:, m ,n));

    end
TotalCost(m) = mean(TotalCost_GDRO(m,:));
fprintf('The current iteration = %g\n',m)
end


%% Plot

yyaxis left
plot(k, TotalCost)

yyaxis right
plot(k, Probability)

toc
