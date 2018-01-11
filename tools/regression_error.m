function [rel_mse, rel_mad, corr_coeff] = regression_error(y, z, fid)
	
% function [rel_mse, rel_mad, corr_coeff] = regression_error(y, z, fid)
%
% Print error statistics for regression experiments.
% The original outcome should be given as first input argument,
% the predicted outcome should be the second input argument.
%
% y is a vector of outcomes
% z is a vector of actual outcomes
%
% Optionally, a file id can be given to print results to a log file.
%
% Output arguments:
% rel_mse - Relative (with respect to variance of y) mean square error
% rel_mad - Relative (with respect to mad of y) median absolute deviation
% corr_coeff - correlation coefficient
%
% Christian Merkwirth 2004

N = length(y);

rel_mse = relepsinloss(y,z,0);
rel_mad = median(abs(y-z)) / median(abs(y-median(y)));

ym = y(:) - mean(y);
zm = z(:) - mean(z);

corr_coeff = ym'*zm / (sqrt(ym'*ym)*sqrt(zm'*zm));

if nargin<3
    disp(['Relative mean square error : ' num2str(rel_mse) ' on a total of ' num2str(N) ' samples'])
    disp(['Relative median absolute deviation  : ' num2str(rel_mad)])
    disp(['Correlation coefficient r : ' num2str(corr_coeff)])
    disp(['r^2 : ' num2str(corr_coeff^2)])
else
    fprintf(fid, '%s \n', ['Relative mean square error : ' num2str(rel_mse) ' on a total of ' num2str(N) ' samples']);
    fprintf(fid, '%s \n', ['Relative median absolute deviation  : ' num2str(rel_mad)]);
    fprintf(fid, '%s \n', ['Correlation coefficient r : ' num2str(corr_coeff)]);
    fprintf(fid, '%s \n', ['r^2 : ' num2str(corr_coeff^2)]);
end

