function y = calc(model, urbilder)

% y = calc(model, urbilder)
%
% Christian Merkwirth 2004

if ~isempty(model.uscalefacs)
    urbilder = scale(urbilder, model.uscalefacs);
    urbilder = 0.75 * urbilder;
end

y = perceptron_calc(urbilder, model.net, model.offset);

if ~isempty(model.bscalefac)
    y = y*model.bscalefac(2) / 0.75 + model.bscalefac(1);
end
