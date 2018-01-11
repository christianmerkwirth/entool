function model = set(model, param, value)

% function model = set(model, param, value)
%
% Set properties of boostregensemble object.
%
% Christian Merkwirth 2002

switch(lower(param))
   otherwise
      model.ensemble = set(model.ensemble, param, value);
      %warning(['Parameter ' param ' is not element of class ensemble'])
end

