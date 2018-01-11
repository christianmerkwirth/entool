function [beta, mx, Sd, gcverrs, optimallambda, yloo] = svdridge(x, y, lambda, svdcutoff, epsilon, sampleweights)

% function [beta,mx, Sd, gcverrs, optimallambda] = svdridge(x, y, lambda, svdcutoff, epsilon, (sampleweights))
%
% If a vector of lambdas is given, the algorithm will try to choose the one
% with results in least GCV (generalized cross validation error).
%
% If a negative epsilon is given, the function assumes binary
% classification and tries to optimize the AUC (area under the curve in the
% roc plot). The vector of desired outputs y should then be 0/1.
%
%
% Christian Merkwirth 2003


[N,D] = size(x);

svdcutoff = svdcutoff * sqrt(N);

% Normalize input matrix x
mx = sum(x,1) / N;
X = x - repmat(mx,N,1);
stdX = sqrt(sum(X.*X,1) / N);

ind = find(stdX < 1e-10);
stdX(ind) = inf;
X = X ./ repmat(stdX,N,1);

% Add intercept
X = [X ones(N,1)];

% Care for weighted regression problem
if nargin > 5
    w = sqrt(sampleweights(:));
    
    y = w .* y;
    X = full(sparse((1:N),(1:N), w) * X);
else
    w = ones(N,1);
end

if (D+1) < N
    if issparse(X)
        [U,S,V] = svds(X,0);
    else
        [U,S,V] = svd(X,0);
    end
else
    if issparse(X)
        [V,S,U] = svds(X',0);
    else
        [V,S,U] = svd(X',0);
    end
end


% Alternative way to compute 
%beta = inv(X'*X + diag([(lambda*lambda * ones(D,1)); 0])) * X' * y;
% beta = V * inv(S.*S + V' * diag([(lambda*lambda * ones(D,1)); 0]) * V) * diag(S1) * U'* y;

% Application of Sherman Morrison formula for this special diagonal basic matrix 
% See Numerical Recipes
% We set :
% A = S * S + lm * I
% Ad = diag(A^(-1))
% B = (A + V' * diag([0 0 0 0 0 1]) * V)
% Bi = B^(-1)

if size(S,1) < size(S,2)
    % in case we have more variables than observations, cut sizes of
    % matrices
    S = S(:, 1:size(S,1));
end

Sd = diag(S);

%bar(Sd);  pause

ind = find(Sd <= svdcutoff);
Sd(ind) = inf;

betas = [];
gcverrs = [];   % generalized cross-validation errors
yloo = [];

lmd = lambda(:) .* lambda(:);  % 

for lm = lmd'
    Ad = 1./ (Sd.*Sd + lm);
    
    u = V(end,:)';
    z = u(1:min(length(u), length(Ad)))  .* Ad;
    b = u(1:min(length(u), length(Ad)))' * z;
    Bi = diag(Ad) - (-lm) * (z * z')/(1.0 + (-lm) * b);
    
    A = V(:,1:min(size(V,2), size(Bi,1))) * Bi * S * U';
    
    beta = A * y;
    
    yh = X * beta;
    
    %     if any((1.0-diag(X*A))==0)
    %         keyboard
    %     end
    
    dXA = sum(X' .*A)'; % = diag(X*A);
    
    indones = find(dXA == 1.0);
    
    if isempty(indones)
        yhgcv = y + (yh-y)./(1.0-dXA);
        
        if epsilon < 0
            gcverrs(1,end+1) = -auc(y, yhgcv); 
        else
            gcverrs(1,end+1) = relepsinloss(y, yhgcv, epsilon); 
        end
        yloo(:,end+1) = yhgcv;
    else
        gcverrs(1,end+1) = inf;
        yloo(:,end+1) = y + inf;    
    end
    betas(:,end+1) = beta;
end

[dummy,ind] = min(gcverrs);

beta = betas(:,ind);
optimallambda = lambda(ind);
yloo = yloo(:,ind);

beta(1:D) = beta(1:D) ./ stdX';

