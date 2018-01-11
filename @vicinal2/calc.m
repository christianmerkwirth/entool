function y = calc(atria, urbilder)

% y = calc(atria, urbilder)
%
% Christian Merkwirth 2002

[nn, d, querypoints] = calcnn(atria, urbilder, atria.trainparams.approximate);
y = calcoutput(atria, nn, d, querypoints, atria.lambda);
