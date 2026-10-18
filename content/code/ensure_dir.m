function ensure_dir(dirPath)
%ENSURE_DIR Create directory if it does not exist.
if ~exist(dirPath, 'dir')
    mkdir(dirPath);
end
end
