function display(ens)

% display(x)
%
% Display content of ensemble object
%
% Christian Merkwirth



disp('Ensemble object:')
disp(struct(ens))
disp(' ')

if length(ens.models)
	ans = input('Detailed list of constituting models ? (n/y)', 's');

	if strcmp(ans, 'y')
   	more on
		disp('Constituting models:')
		for m=1:length(ens.models)
   		disp(['Model Nr. ' num2str(m)])
   		%class(ens.models{m})
   		%class(ens)
			display(ens.models{m})
   	end
   	more off
	else
		for m=1:length(ens.models)
			disp(['Model Nr. ' num2str(m) ' of type ' class(ens.models{m})])   
		end   
	end   
end

