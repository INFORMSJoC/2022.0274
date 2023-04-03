%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 04/10/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;

tic

% Get acess to the current path and add the files in the 'main' folder to path
current_path = pwd; 
[parent_path, ~, ~] = fileparts(current_path); 
addpath(strcat(parentpath, "\main"));

%% Output
% Constraint violation of the solutions of G-ADRO model, which is defined
% by (expected second-stage cost - target)/target.

%% Input Parameters and initialization

N = 10 ;                                                                         % dimension of uncertainty
S = 20 ;                                                                          % in-sample data point
S1 = 1000 ;                                                                     % out-sample data point
D = 40 ;
D1 = 40 ;                                                                   % upper bound of decision and uncertainty
t = xlsread('distance.xlsx','A2:J11');                          % distance matrix
d= xlsread('d_insample.xlsx','A2:T11');                     % training sample matrix
d1 = xlsread('d_outsample.xlsx','A2:BXX11');           % testing sample matrix
c1 = 10*ones(N,1)  ;                                                      % first stage unit cost
c2 = 30*ones(N,1) ;                                                       % emergency unit cost
mu = 20 ;                                                                     % mean value of demand
sigma = 15 ;                                                                % standard deviation of demand
theta = 2 ;
d1(:,1:20) = d(:,1:20);

%% Solve W-DRO model
[x_DRO,opt,lambda] = WassersteinDRO(theta,N,S,D,d,c1,c2,t);

%% Evaluate the second-stage cost under out-of-sample distribution
second_stage_value = SecondStage(N, S1, d1, x_DRO, c2, t);


k = [lambda, 32, 30];  % values of gamma
ballsize = [0 1 2 3 4 5 6 7 8 9 10]; % distance between distributions
for n = 1 : 3
    % Solve the G-ADRO model
    [x(:,n),TotalCost_insample(n)] = GDRnO(N,S,D,D1,d,theta,c1,c2,t,k(n));
    % Determine the target
    T(n) = TotalCost_insample(n) - c1'*x(:,n);
end

for m = 1 : 11
    % Fine the out-of-sample distribution with maximum second-stage cost
    [value(m), p(:,m), q(:,:,m)] = MaximumViolation(S,S1,d,d1,second_stage_value, ballsize(m));
    % Identify effective scenarios
    a = find(p(:,m)>0);
    d_outsample = d1(:,a);
    L = length(a);
    probability = p(a,m);
    for n = 1 : 3
        % Out-of-sample test
        second_stage_GDRO = SecondStage(N, L, d_outsample, x(:,n), c2, t);
        deviation = (second_stage_GDRO - T(n))/T(n);
        Violation(m,n) = p(a,m)'*deviation;
    end
end

toc
