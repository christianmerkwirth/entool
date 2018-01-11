function [w, A, yhat] = linreg(X,y, mu) 

% function [w, A] = linreg(X,y, mu)
%
% Simple linear regression, X is matrix of size N by D,
% containing inputs of dimension D, y is output of size N by 1.
%
% w is the D+1 by 1 vector of coefficients, last entry is the
% offset.
%
% If not given, mu defaults to zero. 
%
% Christian Merkwirth

if nargin < 3
    x = [X ones(size(X,1),1)];
    A = inv(x'*x);
    w = A*x'*y;
    
    if nargout > 2
        yhat = x*w;
    end
else
    mX = mean(X);
    my = mean(y);
    
    x = X - ones(size(X,1),1) * mX; 
    Y = y - my; 
    
    A = inv(x'*x + mu * eye(size(x,2)));
    w = A*x'*Y;
    
    w(end+1) = my - mX * w;
    
    if nargout > 2
	    yhat = X*w(1:(end-1)) + w(end);
    end
end




