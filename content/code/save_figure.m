function save_figure(figHandle, outBasePath)
%SAVE_FIGURE Save figure as .png and .fig.
if nargin < 1 || isempty(figHandle)
    figHandle = gcf;
end
[outDir, ~, ~] = fileparts(outBasePath);
if ~isempty(outDir)
    ensure_dir(outDir);
end

targetWidth = 1793;
targetHeight = 1080;
targetDPI = 150;
targetPaperWidth = targetWidth / targetDPI;
targetPaperHeight = targetHeight / targetDPI;

set(figHandle, 'Color', 'w', 'InvertHardcopy', 'off');
set(figHandle, 'Units', 'pixels', 'Position', [100 100 targetWidth targetHeight]);
set(figHandle, 'PaperUnits', 'inches', ...
    'PaperPosition', [0 0 targetPaperWidth targetPaperHeight], ...
    'PaperSize', [targetPaperWidth targetPaperHeight]);

drawnow;

pngPath = [outBasePath, '.png'];
try
    print(figHandle, pngPath, '-dpng', sprintf('-r%d', targetDPI));
catch
    exportgraphics(figHandle, pngPath, 'Resolution', targetDPI, 'BackgroundColor', 'white');
end
savefig(figHandle, [outBasePath, '.fig']);
end
