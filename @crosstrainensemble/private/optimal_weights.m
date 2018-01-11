function w = optimal_weights(y, outputs, eps, weight_min, weight_max)

% function w = optimal_weights(y, outputs, eps, weight_min, weight_max)
%
% Christian Merkwirth Krakow 2002

range = (weight_max-weight_min);
w = range*rand(size(outputs,2),1)+weight_min;
w = w / sum(w);

err = calc_err(w, y, outputs, eps);

for rounds=1:200
   neww = mutate(w, weight_min, weight_max, range);
   newerr =  calc_err(neww, y, outputs, eps);
   if newerr < err
      err = newerr;
      w = neww;
   end   
end


function w = mutate(w, weight_min, weight_max, range)

ind = randsel(1:length(w));
mut = 0.2*triangle_rand(1,1) * range;
w(ind) = w(ind) + mut;
   
w = w / sum(w);
w(find(w > weight_max)) = weight_max;
w(find(w < weight_min)) = weight_min;
w(find(w < 0.001)) = 0;
w = w / sum(w);

function err = calc_err(w, y, outputs, eps)

z = outputs * w;
err = epsinloss(y,z,eps);

