function mut = fastmutinfo(x,y)

% function mut = fastmutinfo(x,y)
%
% Compute crude, but fast approximation to mutual information of all
% columns of input matrix x versus output vector y.
%
% The output mut will be a vector of length p (when x is a matrix of N by p).
% 
%
% Christian Merkwirth 

[N,p] = size(x);

X = scale([y x]);
y = X(:,1);
x = X(:,2:end);

mut = zeros(1,p);

nr_bins = ceil(sqrt(N/8));

[dummy,q0] = boxcount(y, nr_bins);      % compute entropy of output y

for i=1:p
    [dummy,q] = boxcount([x(:,i) y], nr_bins);  % compute entropy of i-th column of x seperat and entropy of
                                                % x(:,i) and y together
    mut(i) = q(2)- q0 - q(1);                   % I(x,y) = H(x,y) - H(x) - H(y)
    
    %disp([q0 q]);
end

