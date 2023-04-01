%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 04/10/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;

tic

%% Parameters and initialization

N = 10 ;                                                                         % dimension of uncertainty
S = 20 ;                                                                          % in-sample data point
S1 = 1000 ;                                                                     % out-sample data point
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
theta = 2 ;
d1(:,1:20) = d(:,1:20);

[x_DRO,opt,lambda] = WassersteinDRO(theta,N,S,D,d,c1,c2,t);
second_stage_value = SecondStage(N, S1, d1, x_DRO, c2, t);

k = [lambda, 32, 30];
ballsize = [0 1 2 3 4 5 6 7 8 9 10];
for n = 1 : 3
    [x(:,n),TotalCost_insample(n)] = GDRnO(N,S,D,D1,d,theta,c1,c2,t,k(n));
    T(n) = TotalCost_insample(n) - c1'*x(:,n);
end

for m = 1 : 11
    [value(m), p(:,m), q(:,:,m)] = MaximumViolation(S,S1,d,d1,second_stage_value, ballsize(m));
    a = find(p(:,m)>0);
    d_outsample = d1(:,a);
    L = length(a);
    probability = p(a,m);
    for n = 1 : 3
        second_stage_GDRO = SecondStage(N, L, d_outsample, x(:,n), c2, t);
        deviation = (second_stage_GDRO - T(n))/T(n);
        Violation(m,n) = p(a,m)'*deviation;
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

    end
end

toc