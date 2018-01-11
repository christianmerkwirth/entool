function y = smooth(x, n)

% function y = smooth(x, n)
%
% Smooth scalar time series by averaging #n splines fitted to the input data x.
%
% Christian Merkwirth 2002

nr_samples = length(x);

x2 = x(:);

y = [];

N = n;

for i=1:N
   	ind = unique([1 (i:N:nr_samples) nr_samples]);
   	y(:,end+1) = akimaspline(ind, x2(ind), 1:nr_samples);
   	%y(:,end+1) = cubicspline(ind, x2(ind), 1:nr_samples);
end

y = mean(y, 2);
y = reshape(y, size(x));


