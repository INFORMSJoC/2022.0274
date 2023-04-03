% This function is used to solve the G-ARS model

%% Input Parameters
% N: dimension of uncertainty
% S: number of in-sample data point
% D: upper bound of decision
% D1: upper bound of uncertainty
% d: sample matrix (S × S)
% theta: size of ambiguity set
% T: target
% c1:  first stage unit cost (N × 1)
% c2: emergency unit cost (N × 1)
% t: distance matrix (N × N)

function [k,x,lambda,y,w]= GlobalRnO(N,S,D,D1,d,theta,T,c1,c2,t)

%%%% Model %%%%
model = rsome('GRnO') ;
%% Define random variables
z = model.random(N,1) ; % demand
u = model.random ; % lifted variable

%% Define scenarios and the lifted joint ambiguity set
P = model.ambiguity(S) ;
for s = 1: S
    P(s).suppset (0 <= z , z <= D1 ,norm(z-d(:,s),1)<=u) ;
end
pr = P.prob ;
P.probset(pr==1/S) ;

%% Declare ambiguity set
model.with(P);
%% Define decision variables
k = model.decision() ;
x = model.decision(N,1) ;
y = model.decision(N,N) ;
w = model.decision(N,1) ;
lambda = model.decision() ;
%% Define scenario - wise adaptation
for s = 1: S
    y.evtadapt(s) ;
    w.evtadapt(s) ;
end
%% Define affine adaptation
y.affadapt(z) ;
y.affadapt(u) ;
w.affadapt(z) ;
w.affadapt(u) ;
%% Define objective function
model.min(k) ;
%% Define constraints
model.append(c1'* x + lambda*theta + expect(sum(sum( t .* y ) ) + c2'* w - lambda*u)<= T ) ;
for i = 1: N
    model.append( z(i) - x(i) - w(i) + sum(y(i ,:)) - sum( y(: , i ) ) <= 0) ;
end
model.append(y>=0);
model.append(w>=0);
model.append(x>=0);
model.append(x<=D);
model.append(lambda>=0);
model.append(lambda<=k);
%% Solution
model.solve ;

x = x.get ;
k = k.get ;
lambda = lambda.get;
y = y.get ;
w = w.get;
end