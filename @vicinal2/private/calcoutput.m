function y = calcoutput(model, nn, d, querypoints, lambda)

%  y = calcoutput(model, nn, d, querypoints)
%
% Christian Merkwirth 2002

if model.linear
    y(:,1) = locallinear(model.images, model.dataset, nn, d, model.type, querypoints, lambda);  
else
    y(:,1) = localweighting(model.images, nn, d, model.type);
end

