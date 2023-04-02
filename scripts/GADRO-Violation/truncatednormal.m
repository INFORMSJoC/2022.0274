function d=truncatednormal(mu,sigma,D,N,S)

d=normrnd(mu,sigma,[N,S]);
for i=1:N
    for j=1:S
        if  d(i,j) < 0 
            d(i,j) = 0 ;
        else
            if d(i,j) > D
                d(i,j) = D ;
            end
        end
    end
end

end