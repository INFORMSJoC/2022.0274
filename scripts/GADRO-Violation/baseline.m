%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 04/05/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This function is used to compute the baseline value ,i.e. Empirical Optimization Model.

function [x,opt] = baseline(N,S,D,d,c1,c2,t)

%%%% Model %%%%
model = rsome('Baseline') ;
%% Define random variables
z = model.random(N,1) ; % demand

%% Define scenarios and the lifted joint ambiguity set
P = model.ambiguity(S) ;
for s = 1: S
    P(s).suppset(z==d(:,s)) ;
end

pr = P.prob ;
P.probset(pr == 1/S) ;

%% Declare ambiguity set
model.with(P) ;
%% Define decision variables
y = model.decision(N,N) ;
w = model.decision(N,1) ;
x = model.decision(N,1) ;
% %% Define scenario - wise adaptation
for s = 1: S
    y.evtadapt(s) ;
    w.evtadapt(s) ;
end

y.affadapt(z) ;
w.affadapt(z) ;
%% Define objective function
model.min(c1'*x + expect(sum(sum( t .* y ) ) + c2'* w )  ) ;
%% Define constraints
for i = 1: N
    model.append(z(i) - x(i) - w(i) + sum( y(i ,:) ) - sum( y(: , i ) ) <= 0) ;
end
model.append( y >= 0);
model.append( w >= 0);
model.append( x >= 0);
model.append( x <= D);
%% Solution
model.solve ;

opt = model.get;
x = x.get;

end
