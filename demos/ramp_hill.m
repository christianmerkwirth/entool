function [x,y] = ramp_hill(varargin)

% function [x,y] = ramp_hill
% 
% [x,y] = ramp_hill(N)
% [x,y] = ramp_hill(x1,x2)
%
%
% Generate #N samples of the ramp hill problem, where the inputs are
% chosen randomly from the plane [-1 1] by [-1 1].
%
% Christian Merkwirth 2002

if nargin == 0
	[X,Y] = meshgrid(-1:0.05:1,-1:0.05:1);
   
   x = [X(:) Y(:)];
   y = rh(x);
   
	surf(X,Y, reshape(y,size(X)))
	rotate3d on
elseif nargin == 1
   x = 2*rand(varargin{1},2) - 1;	   
   y = rh(x);
else   
   x = [varargin{1} varargin{2}]; 	
   y = rh(x);   
end   

function y = rh(x)

N = size(x,1);

d_b = sqrt((x(:,1)+0.4).^2+(x(:,2)+0.4).^2);


y_b = zeros(N,1);
ind = find(d_b < 1);
y_b(ind) = 2*cos(pi*d_b(ind));
y_b(find(y_b < 0)) = 0;

y_l = 2*x(:,1) + 2.5*x(:,2) - 0.5;

y = y_b+1;

ind = find(y_l < 0);
y(ind) = y_b(ind)-1;

ind = find((y_l >= 0) & (y_l <= 2));
y(ind) = y_b(ind) + y_l(ind) - 1;
