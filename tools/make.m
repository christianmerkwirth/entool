function make(varargin)

% function make(varargin)
%
% Compile cpp files to mex files if the cpp files are of newer data than
% the respective mex files.
% 
% All optional arguments will be past through to the mex routine
%
% Christian Merkwirth 2004

clear functions

% Compile all .cpp to mex files
d = dir('*.cpp');

for i=1:length(d)
    [pathstr,name,ext] = fileparts(d(i).name);
    d2 = dir(fullfile(pathstr, [name '.' mexext]));    
    if  isempty(d2) || datenum(d(i).date) > datenum(d2(1).date)
        disp(['Making file ' name]);
        try
            mymex(d(i).name, '-DPARTIAL_SEARCH', varargin{:});    
            disp(['Making file ' name ' seems to be successful']);
        catch
            warning(['Compiling of ' name ' failed!'])
            disp(lasterr)
        end
    else
        disp(['File ' name ' is up to date!']);
    end
end

% Check for mex files without respective .cpp and .m files
disp(' ')
disp(' ')

d = dir(['*.' mexext]);

for i=1:length(d)
    [pathstr,name,ext] = fileparts(d(i).name);
    d2 = dir(fullfile(pathstr, [name '.cpp'])); 
    
    if  isempty(d2)
        disp(['File ' name ' is without C++ source!']);
    end
    
    d2 = dir(fullfile(pathstr, [name '.m'])); 
    if  isempty(d2)
        disp(['File ' name ' is without .m file (for help text)!']);
    end
end


function mymex(target, varargin)

if isunix
	mex( '-I..', '-I.', varargin{:},  '-O', target);    % '-v',
else
	mex( '-I..', '-I.', varargin{:}, '-O', target);     % '-v',
end
