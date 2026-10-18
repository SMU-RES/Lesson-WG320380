function metrics = analyze_frequency_domain(model, outFigDir)
%ANALYZE_FREQUENCY_DOMAIN Generate root locus, Bode, Nyquist plots.
ensure_dir(outFigDir);
G = model.tf;

f1 = figure('Name','Root Locus','Color','w');
rlocus(G); grid on; title('Nomoto Model Root Locus');
save_figure(f1, fullfile(outFigDir, 'root_locus_nomoto'));

f2 = figure('Name','Bode','Color','w');
bode(G); grid on; title('Nomoto Model Bode Diagram');
save_figure(f2, fullfile(outFigDir, 'bode_nomoto'));

f3 = figure('Name','Nyquist','Color','w');
nyquist(G); grid on; title('Nomoto Model Nyquist Diagram');
save_figure(f3, fullfile(outFigDir, 'nyquist_nomoto'));

[Gm, Pm, Wcg, Wcp] = margin(G);
metrics = struct('GainMargin', Gm, 'PhaseMargin', Pm, 'Wcg', Wcg, 'Wcp', Wcp);
end
