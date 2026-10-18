function root = package_root()
%PACKAGE_ROOT Return absolute root folder of the submission package.
thisFile = mfilename('fullpath');
codeDir = fileparts(thisFile);
root = fileparts(codeDir);
end
