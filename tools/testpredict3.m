

x  = load('K:\Projekte\Matlab\extensions\demos\datacomp.dat');
xnew  = load('K:\Projekte\Matlab\extensions\demos\rescontdatacomp.dat');
x = [ x(:); xnew(:) ];

%x = sin(0:0.1459248:1000)';

x = chaosys(30000, 0.020, [0.2*triangle_rand(1,1) -0.15*triangle_rand(1,1) 0.05*triangle_rand(1,1)], 0);
x = x((end-12999):end,1);

dim = [];
delay = [];
windowlen = [60:4:120];

for i=1:length(windowlen)
    f = factor(windowlen(i));
    f = f(randperm(length(f)));
    dim(i) = prod(f(1:(end-1))); 
    delay(i) = f(end);
end

nnr = ceil(rand(size(dim))*2);
modes = [0 1 1  2 2 2  3 3 3];
mode = modes(ceil(rand(size(dim)) * length(modes)));     
metric = (1/3*(1.0 + 2*rand(size(dim)))).^(1./dim);

y = predict3(x(1:12000), dim, delay, 1000, nnr, mode, metric,0);

plot(x); hold on; plot(y,'r'); hold off
