function run_tests()
%RUN_TESTS Minimal package tests for required functions and outputs.
root = package_root();
figDir = fullfile(root, 'figures');
resDir = fullfile(root, 'results');

p = params_nomoto();
assert(abs(p.K - 0.1085) < 1e-12, 'K parameter mismatch');
assert(abs(p.T - 9.9447) < 1e-12, 'T parameter mismatch');

m = nomoto_model(p);
assert(isequal(size(m.A), [2 2]), 'A size invalid');
assert(isequal(size(m.B), [2 1]), 'B size invalid');
assert(isequal(size(m.C), [1 2]), 'C size invalid');

requiredPng = {
    'root_locus_nomoto.png'
    'bode_nomoto.png'
    'nyquist_nomoto.png'
    'step_damping_cases.png'
    'ramp_response_error_underdamped.png'
    'pid_heading_response.png'
    'los_path_tracking.png'
    'pid_vs_stw_disturbance.png'
    'rudder_angle_comparison.png'
};

minWidth = 1600;
minHeight = 900;

for i = 1:numel(requiredPng)
    fp = fullfile(figDir, requiredPng{i});
    assert(exist(fp, 'file') == 2, ['Missing figure: ', fp]);
    info = imfinfo(fp);
    assert(info.Width >= minWidth && info.Height >= minHeight, ...
        sprintf('Figure too small: %s (%dx%d)', fp, info.Width, info.Height));
end

referencePath = fullfile(figDir, 'bode_nomoto1.png');
targetPath = fullfile(figDir, 'bode_nomoto.png');
if exist(referencePath, 'file') == 2
    refInfo = imfinfo(referencePath);
    targetInfo = imfinfo(targetPath);
    assert(targetInfo.Width == refInfo.Width && targetInfo.Height == refInfo.Height, ...
        sprintf('bode_nomoto size mismatch: got %dx%d, expected %dx%d', ...
        targetInfo.Width, targetInfo.Height, refInfo.Width, refInfo.Height));
end

assert(exist(fullfile(resDir,'metrics_summary.csv'),'file')==2, 'Missing metrics summary CSV');
assert(exist(fullfile(resDir,'all_metrics.mat'),'file')==2, 'Missing all_metrics.mat');

fprintf('All tests passed.\n');
end
