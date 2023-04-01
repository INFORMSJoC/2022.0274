function [value, p, q] = MaximumViolation(S,S1,d_test,d1_test,second_stage_value, ballsize)
%%%% Model %%%%
model = rsome('maximum violation') ;
p = model.decision(S1,1);
q = model.decision(S,S1);

model.max(p'*second_stage_value)

vector_norm = ones(S,S1);
for m = 1 :S 
    for n = 1 : S1
        vector_norm(m,n) = norm(d_test(:,m) - d1_test(:,n),1);
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