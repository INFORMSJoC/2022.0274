%%% This function is to obtain an out-of-sample distribution with maximum 
%%% second-stage cost subject to the constraint d(\hat{P},P_{out}) = theta.

%% Input
% S: the number of (empirical) training samples 
% S1: the number of (out-of-sample )testing samples
% d: training sample matrix (N × S)
% d1: testing sample matrix (N × S1)
% second_stage_value: second-stage cost vetor under each testing demand sample (S1 × 1)
% ballsize: distance between empirical distribution and out-of-sample distribution

%% Output
% value: maximum second-stage cost under out-of-sample distribution
% p: probability vector of the out-of-sample distribution (S1 × 1)
% q: joint probability matrix


function [value, p, q] = MaximumViolation(S,S1,d,d1,second_stage_value, ballsize)
%%%% Model %%%%
model = rsome('maximum violation') ;
p = model.decision(S1,1);
q = model.decision(S,S1);

%% Define objective---expected second-stage cost
model.max(p'*second_stage_value)

%% Define constraints---distance
vector_norm = ones(S,S1);
for m = 1 :S 
    for n = 1 : S1
        vector_norm(m,n) = norm(d(:,m) - d1(:,n),1);
    end
end

model.append(sum(sum(vector_norm.*q)) <= ballsize);

model.append(ones(1,S)*q == p')
model.append(ones(1,S1)*p == 1)
model.append(ones(1,S1)*q' == 1/S*ones(1,S))
model.append(q >= 0)
model.append(p >= 0)

model.solve;

p = p.get;
q = q.get;

value = model.get;