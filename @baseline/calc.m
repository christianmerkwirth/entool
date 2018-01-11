function y = calc(model, urbilder)

% y = calc(model, urbilder)
%
% Christian Merkwirth 2002

N = size(urbilder,1);

y = model.a * ones(N,1);
