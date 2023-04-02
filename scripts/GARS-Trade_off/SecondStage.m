function obj = SecondStage(N,S,d,x,c2,t)

obj = zeros(S,1) ;

for s = 1: S
    %%%% Model %%%%
    model = rsome('violation') ;
    %% Define random variables
    z = model.random(N,1) ; % demand
    
    %% Define scenarios and the lifted joint ambiguity set
    P = model.ambiguity;
    P.suppset (z == d(:,s) ) ;
    
    %% Declare ambiguity set
    model.with(P) ;
    %% Define decision variables
    y = model.decision(N,N) ;
    w = model.decision(N,1) ;
    
%     y.affadapt(z) ;
%     w.affadapt(z) ;
    %% Define objective function
    model.min( sum( sum( t .* y ) ) + c2'* w  ) ;
    %% Define constraints
    for i = 1: N
        model.append(z(i) - x(i) - w(i) + sum( y(i ,:) ) - sum( y(: , i ) ) <= 0) ;
    end
    model.append( y >= 0) ;
    model.append( w >= 0) ;
    %% Solution
    
    model.Param.display = '0';
    model.solve ;
    
    obj(s) = model.get ;
    
end
