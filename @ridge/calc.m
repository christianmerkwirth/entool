function y = calc(model, urbilder)

% y = calc(model, urbilder)
%
% Christian Merkwirth 2002

if isempty(urbilder)
    % Return Leave-One-Out output for the samples of the training data set
    y = model.yloo;
else
    N = size(urbilder,1);
    %y = [(urbilder-ones(N,1)*model.mx) ones(N,1)] * model.coefficients;
    y = [urbilder ones(N,1)] * model.coefficients;
end
