function sampleclass = getsampleclass(bilder, nr_models, frac_test)

% function sampleclass = getsampleclass(bilder, nr_models, frac_test)
%
% Compute multiple column vectors of sampleclasses to train #nr_models models. These 
% column vectors are combined to a matrix of size length(bilder) by nr_models.
% The coding is as follows:
%
% A zero entry at position i indicates that the sample with index i belongs to the training set.
% Any other value indicates that this sample may not be used for training, not even for early stopping
% or any other kind of validation during the training!
%
% From all available samples, the testset is drawn randomly, but with 
% minimal mutual overlap between each pair of column vectors of sampleclass.
%
% Christian Merkwirth 2002

nr_samples = length(bilder);
nr_test = ceil(frac_test * nr_samples);
nr_train = nr_samples - nr_test;

if nr_train < 1
	error('Fraction of test samples is too large');
end

permind = randperm(nr_samples);
permind = permind(:);

shift = nr_test;
   
sampleclass = zeros(nr_samples, nr_models);

for i=1:nr_models
   ind_test = mod((1:nr_test)+floor((i-1)*shift), nr_samples)+1; 
   sampleclass(permind(ind_test),i) = 1;  	 
end
