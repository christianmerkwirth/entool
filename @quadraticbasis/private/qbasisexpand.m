function xx = qbasisexpand(x)

% function xx = qbasisexpand(x)
%
% Expand to quadratic basis
%
%
% Christian Merkwirth 2004

[N,D] = size(x);

xx = zeros(N,D+D*(D+1)/2);

xx(:,1:D) = x;

counter = D+1;

for i=1:D
    for j=i:D
        xx(:,counter) = x(:,i).*x(:,j);
        counter = counter + 1;
    end
end
