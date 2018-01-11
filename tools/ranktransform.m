function [y, zerocolumns] = ranktransform(x)

% function [y, zerocolumns] = ranktransform(x)
%
% Transform x columnwise to rank values out of [0...1]. Ties are group together.
% zerocolumns is an index vector containing numbers of columns with constant entries. 
%
% Christan Merkwirth

[N,p] = size(x);

[s, ind] = sort(x);

d = cumsum([ones(1,p) ; double(diff(s)~=0)])-1;
dd = d(end,:);
zerocolumns = find(dd==0);
dd(zerocolumns) = 1;

d = d./repmat(dd,N,1);

y = x;

for i=1:p
    revind(ind(:,i)) = 1:N;
    y(:,i) = d(revind,i);
end 