%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 01/10/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;

tic

%% Parameters and initialization

N = 10 ;                                                                         % dimension of uncertainty
S = 20 ;                                                                          % in-sample data point
S1 = 2000 ;                                                                     % out-sample data point
D = 40 ;
D1 = 40 ;                                                                   % upper bound of decision and uncertainty
c1 = 10*ones(N,1)  ;                                                      % first stage unit cost
c2 = 30*ones(N,1) ;                                                       % emergency unit cost
mu = 20 ;                                                                     % mean value of demand
sigma = 15 ;                                                                % standard deviation of demand

t = xlsread('C:\Users\liufe\Desktop\distance.xlsx','A2:J11');
d_test= xlsread('C:\Users\liufe\Desktop\d_insample.xlsx','A2:T11');
d1_test = xlsread('C:\Users\liufe\Desktop\d_outsample.xlsx','A2:BXX11');
theta = [0 2 5];
% ballsize = [0,1:30];
ballsize = [4.8 4.9];
[x_SAA,opt] = baseline(N,S,D,d_test,c1,c2,t);

T = 1.084*opt;
%% Solve the GDRO model
for i = 1 : 3
    [k(i), x(:,i), ~] = GlobalRnO(N,S,D,D1,d_test,theta(i),T,c1,c2,t);
end
second_stage_value_RS = SecondStage(N, S1, d1_test, x(:,1), c2, t);
TotalCost_RS = c1'*x(:,1) + second_stage_value_RS;

for m = 1 : length(ballsize)
    [Value(m), p(:,m), q(:,:,m)] = MaximumViolation(S,S1,d_test,d1_test,TotalCost_RS,ballsize(m));
    a = find(p(:,m)>0);
    second_stage_value = ones(length(a),1);
    d_outsample = d1_test(:,a);
    for i = 1 : S
        for j = 1 : S1
            d_vector(i,j) = norm(d_test(:,i) - d1_test(:,j),1);
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
%         fprintf('The deviation = %g\n',deviation)
        TotalCost_GDRO(m,n) = p(a,m)'*TotalCost;
        weight1 = 0;
        weight2 = 0;
        for k = 1 : length(a)
            if deviation(k) < 0
                shortfall(k,m,n) = -deviation(k)*probability(k);
                weight1 = weight1 + probability(k);
                surplus(k,m,n) = 0;
            elseif deviation(k) >0
                surplus(k,m,n) = deviation(k)*probability(k);
                weight2 = weight2 + probability(k);
                shortfall(k,m,n) = 0;
            end
        end
        st = shortfall(:,m,n);
        st = st(st>0);
        sp = surplus(:,m,n);
        sp = sp(sp>0);
        Shortfall(m,n) = sum(st)/weight1;
        Surplus(m,n) = sum(sp)/weight2;
        
        Shortage_original(m,n) = TotalCost_GDRO(m,n) - T;
        fprintf('The number of Inner Iterations = %g\n',n)
    end
    fprintf('The number of Outer Iterations = %g\n',m)
end

toc