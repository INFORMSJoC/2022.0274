%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 01/10/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;

tic

%% Output
% Constraint violation of the solutions of G-ARS model, which is defined
% by (expected second-stage cost - target)/target.

%% Input Parameters and initialization

N = 10 ;                                                                         % dimension of uncertainty
S = 20 ;                                                                          % in-sample data point
S1 = 2000 ;                                                                     % out-sample data point
D = 40 ;
D1 = 40 ;                                                                   % upper bound of decision and uncertainty
c1 = 10*ones(N,1)  ;                                                      % first stage unit cost
c2 = 30*ones(N,1) ;                                                       % emergency unit cost
mu = 20 ;                                                                     % mean value of demand
sigma = 15 ;                                                                % standard deviation of demand

t = xlsread('distance.xlsx','A2:J11');                          % distance matrix
d= xlsread('d_insample.xlsx','A2:T11');                     % training sample matrix
d1 = xlsread('d_outsample.xlsx','A2:BXX11');           % testing sample matrix
theta = [0 2 5];
% ballsize = [0,1:30];
ballsize = [4.8 4.9];
[x_SAA,opt] = baseline(N,S,D,d,c1,c2,t);

T = 1.084*opt;
for i = 1 : 3
    % Solve the G-ARS model
    [k(i), x(:,i), ~] = GlobalRnO(N,S,D,D1,d,theta(i),T,c1,c2,t);
end
% Calcuate the second-stage cost under each demand point
second_stage_value_RS = SecondStage(N, S1, d1, x(:,1), c2, t);
TotalCost_RS = c1'*x(:,1) + second_stage_value_RS;

for m = 1 : length(ballsize)
    % Fine the out-of-sample distribution with maximum second-stage cost
    [Value(m), p(:,m), q(:,:,m)] = MaximumViolation(S,S1,d,d1,TotalCost_RS,ballsize(m));
    % identify effective scenarios
    a = find(p(:,m)>0);
    second_stage_value = ones(length(a),1);
    d_outsample = d1(:,a);
    for i = 1 : S
        for j = 1 : S1
            d_vector(i,j) = norm(d(:,i) - d1(:,j),1);
        end
    end
    dist(m) = sum(sum(d_vector.*q(:,:,m)));
    probability = p(a,m);
    for n = 1 : 3
        %% Out-of-Sample Testing
        %Second-stage cost
        second_stage_value = SecondStage(N, length(a), d_outsample, x(:,n), c2, t);
        
        TotalCost = second_stage_value + c1'*x(:,n);
        deviation = TotalCost - T;

        TotalCost_GDRO(m,n) = p(a,m)'*TotalCost;
        violation(m, n) = (TotalCost_GDRO(m,n)-T)/T;
    end
    fprintf('The number of Outer Iterations = %g\n',m)
end

toc